import XCTest
@testable import FileManBase

final class FileManTests: XCTestCase {
	
	func testExample() throws {


		let fm = FileManager(base: .home)
		
		
		let userDir = FileManager.default.homeDirectoryForCurrentUser.relativePath
		
		print(fm.currentDirectoryPath, userDir)
		XCTAssertEqual(fm.currentDirectoryPath, userDir)
		
	}
	
}
