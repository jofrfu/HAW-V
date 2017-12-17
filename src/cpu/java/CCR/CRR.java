import java.io.*;
import java.util.Map;
import java.util.TreeMap;

//Programm to convert results into vhdl file
public class CRR {
    static final String NOP = "x\"13\", x\"06\", x\"16\", x\"00\",";
    
    /**
     * Takes the bin file to convert to vhdl by array (Only 32Bit)
     * @param args[0] the register Result file to read
     */
    public static void main(String [ ] args){
        Map<Integer, Long> regVal = new TreeMap<>();

        File in_f = new File(args[0]);
        File out_f = new File("RegResults.vhdl");

        if(!in_f.exists()) {
            System.out.println("Input file not found in: ");
            System.out.println(new File(".").getAbsoluteFile());
            System.exit(-1);
        }
            
        try {
            if(!out_f.createNewFile()) {
                System.out.println("Output File already there, will be deleted!");
                if(!out_f.delete() && !out_f.createNewFile()) {
                    System.out.println("File deletion failed");
                }
            }
        } catch (IOException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
            System.exit(-1);
        }
        
        BufferedReader in;
        FileWriter out;
        
        try {
            int line = 0;
            in = new BufferedReader(new FileReader(in_f));
            out = new FileWriter(out_f);
            String read = in.readLine();
            line++;
            String regAndVal[];
            int register;
            long value;
            while(read != null){
                regAndVal = read.split(" ");
                if(regAndVal.length > 2){ //only the register and value should be here
                    System.out.println("Error in line: " + line);
                }
                register = Integer.parseInt(regAndVal[0].substring(1)); //TODO check register
                int radix;
                switch(regAndVal[1].substring(0,2)){
                    case "0b": radix =  2; break;
                    case "0e": radix =  8; break;
                    case "0t": radix = 10; break;
                    case "0x": radix = 16; break;
                    default: System.out.println("Error @ line " + line + " Radix must be either 0b, 0e, 0t or 0x but was " + regAndVal[1].substring(0,1)); return;
                }
                try{
                    value = Long.parseLong(regAndVal[1].substring(2), radix);
                } catch (NumberFormatException e){
                    System.out.println("Error @ line " + line + " Cant parse register value"); return;
                }
                regVal.put(register, value);

                read = in.readLine();
                line++;
            }

            StringBuilder sbRegCheck = new StringBuilder();
            StringBuilder sbValues= new StringBuilder();

            for (Map.Entry<Integer, Long> entry : regVal.entrySet()) {
                sbRegCheck.append("    "+entry.getKey() + ",\r\n");

                sbValues.append("    \"" + Long.toBinaryString(entry.getValue()) + "\",\r\n");
            }

            out.write("use WORK.riscv_pack.all; \r\n" +
                      "package regResults  is \r\n" +
                      "type reg_ar is array (0 to "+ regVal.size() +")) of integer range 0 to 31;\r\n" +
                      "constant REG_TO_CHECK : reg_ar := ( \n");
            sbRegCheck.deleteCharAt(sbRegCheck.length()-1); //delete last ","
            out.write(sbRegCheck.toString() + ");");

            out.write("\r\n\r\ntype reg_resu_ar is array (0 to "+ regVal.size() +")) of DATA_TYPE;\r\n" +
                      "constant REG_TO_CHECK : reg_resu_ar := ( \r\n");
            sbRegCheck.deleteCharAt(sbRegCheck.length()-1); //delete last ","
            out.write(sbValues.toString() + ");");

            out.write("\r\nend package body;");
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