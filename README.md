# FileManBase

SWIFT File Manager Tool 

A simple and convenient collection of frequently used file operations with custom base path. A big advantage is that it handles system directories independently of platform (on macOS and iOS the location of the bundle directory is different).  

Usage: 

```Swift

let fm = FileManager(base: .bundle, directory: "test")
	
print(fm.currentDirectoryPath) 	// -> /Users/MetatronSW/test 
	
let answer = fm.fileExists(baseAnd: "file.txt")
	
```


You can also use the FileManager's existing default instance:

```Swift
	
FileManager.default.setBaseUrl(base: .bundle)
	
FileManager.default.fileReplace(baseAnd: "source.txt", destination: URL(filePath: "/Users/Metatron/Public/destination.txt" ))
		
// -> /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/Library/Xcode/Agents/Contents/Resources/source.txt
// -> /Users/Metatron/Public/destination.txt
	
```



