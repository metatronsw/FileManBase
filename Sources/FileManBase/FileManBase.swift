//    _____ __  __    _    _   _
//   |  ___|  \/  |  / \  | \ | |
//   | |_  | |\/| | / _ \ |  \| |
//   |  _| | |  | |/ ___ \| |\  |  Metatron Software - Swift
//   |_|   |_|  |_/_/   \_\_| \_|  File Manager Tool 2023.08.26.


import Foundation



extension FileManager {
	
	public enum UrlBases {
		
		case bundle, home, temp, desktop, document, download, shared, program
		
		var getUrl: URL {
			switch self {
#if os(iOS) && !targetEnvironment(macCatalyst)
				case .bundle:   return Bundle.main.bundleURL
#elseif os(macOS) && !targetEnvironment(macCatalyst)
				case .bundle:   return Bundle.main.bundleURL.appendingPathComponent("Contents/Resources")
				case .home:     return FileManager.default.homeDirectoryForCurrentUser
				case .temp:     return FileManager.default.temporaryDirectory
#endif
				case .desktop:  return FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first!
				case .document: return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
				case .download: return FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!
				case .shared:   return FileManager.default.urls(for: .sharedPublicDirectory, in: .userDomainMask).first!
				case .program:  return URL(filePath: FileManager.default.currentDirectoryPath)
			}
		}
		
		var getPath: String { self.getUrl.path(percentEncoded: false) }
		
	}
}




extension FileManager {
	
	public static func fileReplace(source: URL, destination: URL) -> Bool {
		
		let bakURL = destination.appendingPathExtension(UUID().uuidString)
		
		do {
			try self.default.copyItem(at: source, to: bakURL )
			try self.default.removeItem(at: source)
			try self.default.moveItem(at: bakURL, to: destination)
		} catch {
			print("ERROR: Replace file", source, destination, error.localizedDescription)
			return false
		}
		return true
	}
	
	
	public static func freespace(at: URL) -> Int {
		
		do {
			let systemAttributes = try self.default.attributesOfFileSystem(forPath: at.path(percentEncoded: false))
			let freeSpace = (systemAttributes[FileAttributeKey.systemFreeSize] as! Int)
			return freeSpace
		} catch {
			print(error.localizedDescription)
			return 0
		}
		
	}
	
}



/// Extension for baseUrl functions
///
@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
extension FileManager {
	
	
	public convenience init(base: UrlBases, directory: String = "") {
		
		self.init()
		self.setBaseUrl(base: base, directory: directory)
	}
	
	
	public func setBaseUrl(base: UrlBases = .home, directory: String = "") {
		
		let root = base.getUrl
		let curDir = root.appending(path: directory).path(percentEncoded: false)
		
		var isDirectory = ObjCBool(false)
		let isExist = FileManager.default.fileExists(atPath: curDir, isDirectory: &isDirectory)
		
		if isExist && isDirectory.boolValue {
			self.changeCurrentDirectoryPath(curDir)
		} else {
			print("ERROR: Bad directory", curDir)
		}
	}
	
	public var currentUrl: URL { URL(filePath: self.currentDirectoryPath) }

	
	private func baseUrl(and file: String) -> URL {
		self.currentUrl.appending(path: file)
	}

	private func basePath(and file: String) -> String {
		self.currentDirectoryPath.appendingFormat("/%@", file)
	}
	
	
	
	/// Base URL and file
	public func fileExists(baseAnd file: String) -> Bool {
		
		let path = basePath(and: file)
		
		var isDirectory = ObjCBool(false)
		let isExist = FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory )
		
		guard !isDirectory.boolValue else { print("No file, it's a directory: ", path) ; return false }
		guard isExist                else { print("No file at path: ", path )          ; return false }
		
		return true
	}
	
	
	public func folderExists(baseAnd folder: String, create: Bool = false) -> Bool {
		
		let path = basePath(and: folder)
		
		var isDirectory = ObjCBool(false)
		let answer = FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)
		let returnState = answer && isDirectory.boolValue
		
		if returnState { return true }
		else { // No Folder
			
			if create {
				do {
					
					try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
					
					print("Folder not exists, but created:", folder)
					return true
					
				} catch {
					print("ERROR: Folder not exists & not created: ", error.localizedDescription)
				}
			}
			
		}
		
		return false
	}
	
		
	@discardableResult
	public func fileSave(baseAnd file: String, string: String) -> Bool {
		
		let path = basePath(and: file)
		
		do {
			try string.write(toFile: path, atomically: true, encoding: .utf8)
			
		} catch {
			print("ERROR: File save: ", file, error.localizedDescription)
			return false
		}
		
		return true
	}
	
	
	@discardableResult
	public func fileSave(baseAnd file: String, data: Data) -> Bool {
		
		let url = baseUrl(and: file)
		
		do {
			try data.write(to: url, options: Data.WritingOptions.atomic)
			
		} catch {
			print("ERROR: File save: ", file, error.localizedDescription)
			return false
		}
		
		return true
	}
	
	
	@discardableResult
	public func fileAppend(baseAnd file: String, string: String) -> Bool {
		
		let path = basePath(and: file)
		
		
		guard let fileHandle = FileHandle(forWritingAtPath: path) else { return false }
		
		defer {
			fileHandle.closeFile()
		}
		
		guard let data = string.data(using: .utf8) else { return false }
		
		do {
			try fileHandle.seekToEnd()
			try fileHandle.write(contentsOf: data)
			
		} catch {
			print("ERROR: File appending: ", file, error.localizedDescription)
			return false
		}
		
		return true
	}
	
	
	@discardableResult
	public func fileDelete(baseAnd file: String) -> Bool {
		
		let path = basePath(and: file)
		
		do {
			try FileManager.default.removeItem(atPath: path)
			
		} catch {
			print("ERROR: Delete file:", file, error.localizedDescription)
			return false
		}
		
		return true
	}
	
	
	public func fileReplace(baseAnd file: String, destination: URL) -> Bool {
		
		let url = baseUrl(and: file)
		
		return FileManager.fileReplace(source: url, destination: destination)
		
	}
	
	
	public func folderFiles(baseAnd folder: String, filterBy fileExtension: String? = nil) -> [String]? {
		
		let path = basePath(and: folder)
		
		guard let fileList = try? FileManager.default.contentsOfDirectory(atPath: path) else { return nil }
		
		/// Filtering
		if let fileExtension, fileList.count > 0 {
			let ext = "." + fileExtension
			return fileList.filter { $0.suffix(ext.count) == ext }
		}
		
		return fileList
	}
	
	
	public func fileLoad(baseAnd file: String) -> String? {
		
		let url = baseUrl(and: file)
		
		do {
			let fileContent = try String(contentsOf: url, encoding: .utf8)
			return fileContent
			
		} catch {
			print("ERROR: Loading file:", file, error.localizedDescription)
			return nil
		}
		
	}
	
	
	public func fileLoad(baseAnd file: String) -> Data? {
		
		let url = baseUrl(and: file)
		
		do {
			let dataContent = try Data(contentsOf: url)
			return dataContent
			
		} catch {
			print("ERROR: Loading file:", file, error.localizedDescription)
			return nil
		}
		
	}
	
	
	public func jsonEncode<Object: Encodable>(baseAnd file: String, object: Object) {
		
		let url = baseUrl(and: file)
		
		let encoder = JSONEncoder()
		encoder.outputFormatting = .prettyPrinted
		
		do {
			let data = try encoder.encode(object)
			try data.write(to: url, options: Data.WritingOptions.atomicWrite)
			
		} catch {
			print("ERROR Archive file:", file, error.localizedDescription)
		}
	}
	
	
	public func jsonDecode<Object: Decodable>(baseAnd file: String) -> Object? {
		
		let url = baseUrl(and: file)
		
		do {
			let data = try Data(contentsOf: url, options: .alwaysMapped)
			let obj = try JSONDecoder().decode(Object.self, from: data)
			return obj
			
		} catch {
			print("ERROR Archive file:", file, error.localizedDescription)
			return nil
		}
		
	}
	
	
}






extension URL {
	
	public var info: String {
  """
  Path:              \(self.path(percentEncoded: false))
  Absolutestring:    \(self.absoluteString)
  Absoluteurl:       \(self.absoluteURL)
  Baseurl:           \(self.baseURL as Any)
  Pathcomponents:    \(self.pathComponents)
  Lastpathcomponent: \(self.lastPathComponent)
  Pathextension:     \(self.pathExtension)
  FileExists:        \(FileManager.default.fileExists(atPath: self.path(percentEncoded: false)))
  IsFileURL:         \(self.isFileURL)
  Hasdirectorypath:  \(self.hasDirectoryPath)
  """
	}
	
}
