from modulefinder import ModuleFinder

finder = ModuleFinder()
finder.run_script('LinuxSchedulerWindow.py')


print("Loaded Modules")
for name, mod in finder.modules.items():
    print(name)
    print("," + str(list(mod.globalnames.keys())[:3]))

print('-' * 50)
print("Modules not imported:")
print(finder.badmodules.keys())
