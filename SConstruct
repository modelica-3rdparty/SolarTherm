import os, sys, platform, shutil; from pathlib import Path
import subprocess as sp

# build script for SolarTherm -- use 'scons' to run it.
# philopsophy here is:
#    - Needed tools like 'solstice' etc should be in the PATH at build-time
#    - We will provide a script called 'st' that makes all required environment var settings
#      at run-time, to try to avoid any challenges for configuration for the end user.
#    - We assume that Solstice is installed on Windows using our Windows installer.
#    - Ultimately we are aiming for a setup process that can be completely automated using
#      standard package managers like apt-get and pacman, but we're not there yet.

default_prefix=Path.home()/'.local'
default_pyversion = "%d.%d" % (sys.version_info[0],sys.version_info[1])

print('system',platform.system())
if platform.system()=="Windows" or "MINGW" in platform.system():
	if os.environ.get('MSYSTEM') == "MINGW64":
		default_prefix=Path(os.environ['HOME'])/'.local'
		default_om_prefix = default_prefix
		default_glpk_prefix = default_prefix
		default_om_libpath = '$OM_PREFIX/lib/omc'
		default_om_bin = '$OM_PREFIX/bin'
		default_om_libs = ['SimulationRuntimeC','omcgc']
		default_install_omlibrary = '$PREFIX/lib/omlibrary'
	else:
		raise RuntimeError("On Windows, you must use MSYS2 in 64-bit mode.")
else:
	default_om_prefix = "/usr"
	default_glpk_prefix = "/usr"
	default_om_libpath = None
	default_om_libs = []
	default_om_bin = '$OM_PREFIX/bin'
	default_install_omlibrary = Path(os.environ['HOME'])/'.openmodelica'/'libraries'#'$PREFIX/lib/omlibrary'

if shutil.which('dakota'):
	default_dakota_prefix = Path(shutil.which('dakota')).parent.parent
else:
	default_dakota_prefix = Path(os.environ['HOME'])/'.local'

default_colors='auto'
if sys.stdout.isatty():
	default_colors = 'yes'

vars = Variables()
vars.AddVariables(
	PathVariable('PREFIX'
		,'File installation prefix'
		,default_prefix
		,PathVariable.PathIsDirCreate)
	,PathVariable(
		'INSTALL_OMLIBRARY'
		,'Installation path for Modelica code'
		,default_install_omlibrary,PathVariable.PathIsDirCreate)
	,PathVariable(
		'INSTALL_OM_ST'
		,'Installation path for Modelica SolarTherm library'
		,'$INSTALL_OMLIBRARY/SolarTherm', PathVariable.PathIsDirCreate)
	,PathVariable(
		'INSTALL_OM_EXT'
		,'Installation path for Modelica external functions'
		,'$INSTALL_OM_ST/Resources/Library', PathVariable.PathIsDirCreate)
	,PathVariable(
		'INSTALL_BIN'
		,"Installation path for the 'st' script"
		,'$PREFIX/bin', PathVariable.PathIsDirCreate)
	,('PYVERSION','Version of Python to use',default_pyversion)
	,('PYTHON','Python executable','python%s'%(sys.version_info[0]))
	,('PYTHON_SHEBANG','Python as named in the `st` shebang',"/usr/bin/env $PYTHON")
	,PathVariable(
		'OM_PREFIX'
		,"Installation prefix for location where OpenModelica is installed"
		,default_om_prefix)
	,PathVariable(
		'OM_CPPPATH'
		,"Location where OM C runtime headers are located"
		,"$OM_PREFIX/include/omc/c")
	,('OM_LIBS',"Libraries to link when building external functions",default_om_libs)
	,('OM_BIN',"Libraries to link when building external functions",default_om_bin)
	,('OM_LIBPATH',"Location of OpenModelicaRuntimeC in particular",default_om_libpath)
	,PathVariable(
		'GLPK_PREFIX'
		,"Installation prefix for GLPK"
		,default_glpk_prefix)
	,PathVariable('GLPK_CPPPATH' ,"Location where GLPK headers are located" ,"$GLPK_PREFIX/include")
	,PathVariable('GLPK_LIBPATH' ,"Location where GLPK libraries are located" ,"$GLPK_PREFIX/lib")
	,PathVariable(
		'DAKOTA_PREFIX'
		,"Installation prefix for GLPK"
		,default_dakota_prefix,PathVariable.PathAccept)	
	,PathVariable('DAKOTA_BIN' ,"Location where DAKOTA executable is located" ,"$DAKOTA_PREFIX/bin",PathVariable.PathAccept)
	,PathVariable('DAKOTA_PYTHON'
		,"Location where DAKOTA python module is located"
		,"$DAKOTA_PREFIX/share/dakota/Python",PathVariable.PathAccept)
	,EnumVariable('COLORS',"Whether to use colour in output",default_colors,['yes','no','auto'])
	,BoolVariable('DEBUG',"Add data for GDB during compilation",False)
)

if platform.system()=="Windows":
	env = Environment(variables=vars,tools=['default','mingw'])
	for v in ['PKG_CONFIG_PATH','PATH','TEMP']:
		if v in os.environ:
			env['ENV'][v] = os.environ[v]
elif platform.system()=="Linux":
	import distro
	env = Environment(variables=vars)
	if distro.id()=="centos":
		# for centos specifically (eg the NCI supercomputer, Gadi) we need this
		# for pkg-config to work correctly.
		for v in ['PKG_CONFIG_PATH','PATH','LD_LIBRARY_PATH']:
			if v in os.environ:
				env['ENV'][v] = os.environ[v]

#---------------------------------------------------------------------------------------------------
# CHECK FOR DAKOTA, SOLSTICE

def check_solstice(ct):
	ct.Message('Checking for solstice...')
	try:
		import solsticepy
		solstice = solsticepy.find_prog('solstice')
		if not solstice:
			raise RuntimeError("Solstice not found by solsticepy")
		sp.run([solstice,'--version'],check=True,stdout=sp.PIPE,stderr=sp.PIPE)
		if platform.system()=='Linux' and solstice == 'solstice':
			solstice = shutil.which('solstice')
	except Exception as e:
		ct.Result(str(e))
		return False
	ct.Result(solstice)
	if platform.system()=="Linux":
		ct.env.AppendUnique(
			ST_PATH= os.path.dirname(solstice)
		)
	return True
def check_dakota(ct):
	ct.Message('Checking for DAKOTA...')
	try:
		dakota = 'dakota'+('.exe' if platform.system()=="Windows" else '')
		dpath = Path(env.subst('$DAKOTA_BIN'))/dakota
		call = [dpath,'--version']
		sp.run(call,check=True,stdout=sp.PIPE,stderr=sp.PIPE)
	except Exception as e:
		ct.Result(str(e))
		ct.env['HAVE_DAKOTA'] = False
		return False
	ct.Result(str(dpath))
	ct.env['DAKOTA'] = dpath
	ct.env['HAVE_DAKOTA'] = True
	ct.env.AppendUnique(
		ST_PATH = [env.subst('$DAKOTA_BIN')]
	)
	return True
def check_dakota_python(ct):
	ct.Message("Checking for 'dakota.interfacing' Python module...")
	dpy = Path(env.subst('$DAKOTA_PYTHON'))
	try:
		assert dpy.exists()
		call = [sys.executable,'-c','"import dakota.interfacing;print dakota.interfacing.__file__"']
		env1 = os.environ.copy()
		env1['PYTHONPATH']=env1['PYTHONPATH'] + os.pathsep + str(dpy)
		sp.run(call,env=env1,check=True)
	except Exception as e:
		ct.Result("Not found (%s)"%(str(e),))
		ct.env['HAVE_DAKOTA']=False
		return False
	ct.Result('OK')
	return True
def check_omc(ct):
	ct.Message("Checking for 'omc'...")
	omc = Path(shutil.which('omc'))
	try:
		assert omc.exists()
		call = [omc,'--version']
		sp.run(call,check=True,stdout=sp.PIPE,stderr=sp.PIPE) # TODO check the version is OK
	except Exception as e:
		ct.Result("Not found (%s)"%(str(e),))
		return False
	ct.Result('OK')
	if str(omc.parent) != '/usr/bin':
		ct.env.AppendUnique(
			ST_PATH = [str(omc.parent)]
#			,ST_LIBPATH = [str(omc.parent.parent/'lib')]
		)
	return True
conf = env.Configure(custom_tests={
	'CS':check_solstice
	, 'DAK':check_dakota
	,'DAKPY':check_dakota_python
	,'OMC':check_omc}
)
if not conf.CS():
	print("Unable to locate 'solstice'")
	Exit(1)
conf.DAK() # we tolerate not finding DAKOTA, use HAVE_DAKOTA later to check
conf.DAKPY()
if not conf.OMC():
	print("Unable to locate OpenModelica compiler 'omc'. Unable to continue.")
	Exit(1)

env = conf.Finish()

#---------------------------------------------------------------------------------------------------

# some tricks required for Ubuntu 18.04...
import platform
configcmd = 'pkg-config python-$PYVERSION-embed --libs --cflags'
if platform.system()=="Linux":
    import distro
    if distro.id() == 'ubuntu' and distro.version() == '18.04':
        configcmd = 'python$PYVERSION-config --libs --cflags'
env['PKGCONFIGPYTHON'] = configcmd

#print("os.environ['PATH']=",os.environ.get('PATH'))
#print("os.environ['PKG_CONFIG_PATH']=",os.environ.get('PKG_CONFIG_PATH'))
#print("env['ENV']['PKG_CONFIG_PATH']=",env['ENV'].get('PKG_CONFIG_PATH'))
#print("env['ENV']['PATH']=",env['ENV'].get('PATH'))

env['VERSION'] = '0.2'
env['SUBST_DICT'] = {
	'@VERSION@' : '$VERSION'
	,'@PYTHON@' : '$PYTHON'
	,'@PREFIX@' : '$PREFIX'
	,'@PYTHON_SHEBANG@' : '$PYTHON_SHEBANG'
	,'@ST_PATH@' : os.pathsep.join('$ST_PATH')
}

if env['COLORS'] == 'yes':
	env.Append(
		CPPFLAGS=['-fdiagnostics-color=always']
		,LINKFLAGS=['-fdiagnostics-color=always']
	)
elif env['COLORS'] == 'no':
	env.Append(
		CPPFLAGS=['-fdiagnostics-color=never']
		,LINKFLAGS=['-fdiagnostics-color=never']
	)

if env['DEBUG']:
	env.Append(
		CPPFLAGS = "-g"
		,LDFLAGS = "-g"
	)


# TODO use 'SConscript(...variant_dir...)
env.SConscript(
	['src/SConscript','tests/SConscript']
	, exports='env'
)

env.AppendUnique(
	ST_PATH=[env.subst('$INSTALL_BIN')]
)

print("Runtime PATHs:",env.get('ST_PATH'))

#---------------------------------------------------------------------------------------------------
# Install (nearly) all files in 'SolarTherm' folder

import re, os, sys

stfiles = []
fre = re.compile(r'^(.*)\.(mo|motab|csv|CSV|txt|order)$')
#print("test.mo:",fre.match('test.mo'))
#sys.exit(1)
def fmatch(root,fns):
	for f in fns:
		if fre.match(f):
			yield str(Path(root)/f)
for root, dirs, fns in os.walk('SolarTherm'):
	r1 = Path(root).relative_to('SolarTherm')
	env.Install('$INSTALL_OM_ST/%s'%(r1,),list(fmatch(root,fns)))

env.Alias('install',['#','$PREFIX','$INSTALL_OMLIBRARY'])

#env.SConscript('examples')
#env.SConscript('resources')

# TODO install SolarTherm directory

# vim: ts=4:noet:sw=4:tw=100:syntax=python
