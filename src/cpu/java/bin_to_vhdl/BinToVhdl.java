

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileWriter;
import java.io.IOException;

public class BinToVhdl {
    static final String NOP = "x\"13\", x\"06\", x\"16\", x\"00\",";
    
    /**
     * Takes the bin file to convert to vhdl by array (Only 32Bit)
     * @param args[0] file to read
     * @param args[1] file to write
     * @param args[2] array constant name
     * @param args[3] package name
     * @param args[4] give "nop_pipeline" (or shor "nop") flag to append No Operation after each cmd
     * @param args[5] number of nops to append after each cmd if nop_pipeline flag was set
     */
    public static void main(String [ ] args){
        File in_f = new File(args[0]);
        File out_f = new File(args[1]);
        int nops = 0;
        
        if(args.length > 4){
            switch(args[4]){
                case "nop_pipeline" : 
                case "nop": nops = Integer.parseInt(args[5]);
            }
        }

        
        if(!in_f.exists()) {
            System.out.println("Input file not found in: ");
            System.out.println(new File(".").getAbsoluteFile());
            System.exit(-1);
        }
        
        try {
            if(!out_f.createNewFile()) {
                System.out.println("File already there, will be deleted!");
                if(!out_f.delete() && !out_f.createNewFile()) {
                    System.out.println("File deletion failed");
                }
            }
            
        } catch (IOException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
            System.exit(-1);
        }
        
        byte buff[] = new byte [4]; //instruction has 4 bytes
        FileInputStream in;
        FileWriter out;
        
        try {
            in = new FileInputStream(in_f);
            out = new FileWriter(out_f);
            
            out.write("library IEEE; \r\n" + 
                      "use IEEE.std_logic_1164.all;" +
                      "package " +  args[3] + " is \r\n" +
                      "type memory is array (natural range 0 to 645120) of std_logic_vector(7 downto 0);\r\n" + 
                      "constant "+ args[2] +" : memory := (");
            
            int bytesRead = 0;
            do{ //read until EOF
                bytesRead = in.read(buff, 0, 4);
                if(bytesRead < 4 && bytesRead != -1) {
                    System.out.println("File read failed");
                    System.exit(-1);
                }
                 StringBuilder sb = new StringBuilder();
                 sb.append("\r\n   ");
                 for(int i = 0; i < 4; i++) {
                    sb.append(String.format(" x\"%02x\",", buff[i]));
                 }
                 for(int i = 0; i < nops; i++) { //inset NOPs
                    sb.append("\r\n    " + NOP);
                 }
                 System.out.print(sb.toString());
                 out.write(sb.toString());
                
            }while(bytesRead != -1);
            out.write("\r\n    others => \"00000000\"\r\n);\r\n" + 
                      "end package " + args[3] + ";");
            out.close();
        } catch (FileNotFoundException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        } catch (IOException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
        
    }
    
    
    
}
