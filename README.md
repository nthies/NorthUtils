[![SPM compatible](https://img.shields.io/badge/SPM-compatible-4BC51D.svg?style=flat)](https://github.com/apple/swift-package-manager)

# NorthUtils

This package contains some small utility executables to use on the command line.
All programs are written in Swift and use 
[NorthLib](https://github.com/nthies/NorthLib). Enter &lt;command&gt; --help to 
get some usage info.
The following executables are available:

- chfn<br/>
  Is some kind of regular expression based file renamer.
  
- unzip<br/>
  Is an executable based on NorthLib to test the zip stream unpacker.
 
## How to build

````
  swift build # build library packages and executables with debug information
  swift build --show-bin-path # show where the executables are located
  swift build -c release # build release version
````

## Author

Norbert Thies, norbert@taz.de

## License

NorthUtils is available under the AGPL. See the LICENSE file for more info.
