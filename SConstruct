env = Environment()

build_dir = 'build'
examples_build_dir = 'examples/build'
Clean('.', build_dir)

SConscript('examples/SConscript',duplicate = 0,variant_dir=examples_build_dir)
SConscript('utils/SConscript',duplicate = 0,variant_dir=build_dir)
Clean('.', build_dir)
Clean('.', examples_build_dir)
