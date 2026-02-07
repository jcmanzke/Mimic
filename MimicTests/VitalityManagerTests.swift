import XCTest
import SwiftData
@testable import Mimic

final class VitalityManagerTests: XCTestCase {
    var viewModel: VitalityManager!
    var modelContainer: ModelContainer!
    
    override func setUp() {
        super.setUp()
        do {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            modelContainer = try ModelContainer(for: PetEntity.self, configurations: config)
            viewModel = VitalityManager(modelContext: modelContainer.mainContext)
        } catch {
            XCTFail("Failed to create ModelContainer: \(error)")
        }
    }
    
    override func tearDown() {
        viewModel = nil
        modelContainer = nil
        super.tearDown()
    }
    
    func testInitialState() {
        XCTAssertEqual(viewModel.health, 1.0)
        XCTAssertEqual(viewModel.scars, 0)
    }
    
    func testDecay() {
        // Decay 10 minutes (10 * 1% = 10% = 0.1)
        viewModel.decompose(minutes: 10)
        XCTAssertEqual(viewModel.health, 0.9, accuracy: 0.001)
    }
    
    func testRecover() {
        viewModel.health = 0.5
        // Recover 20 minutes (20/10 * 0.5% = 1%)
        viewModel.recover(minutes: 20)
        XCTAssertEqual(viewModel.health, 0.51, accuracy: 0.001)
    }
    
    func testHealthBounds() {
        viewModel.decompose(minutes: 200) // -200%
        XCTAssertEqual(viewModel.health, 0.0)
        
        viewModel.recover(minutes: 20000)
        XCTAssertEqual(viewModel.health, 1.0)
    }
}
