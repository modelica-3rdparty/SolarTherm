# Solar Thermal Energy and Economic Performance Simulator (steep)

## Installation
Add the solar thermal libraries where OpenModelica can find them.  The first way to do this is to copy or symbolically link the `STLib` folder in the `~/.openmodelica/libraries/` folder.  On linux creating the symbolic link:

```
mkdir -p ~/.openmodelica/libraries/
cd ~/.openmodelica/libraries
ln -s $STLIBPARENTPATH/STLib STLib
```

Where `$STLIBPARENTPATH` is the directory that contains the `STLib` folder.

The second way to do this is by setting the `OPENMODELICALIBRARY` environment variable:

```
OPENMODELICA=$OPENMODELICAHOME/lib/omlibrary:~/.openmodelica/libraries/:$STLIBPARENTPATH
```

On windows replace the : with ;.
