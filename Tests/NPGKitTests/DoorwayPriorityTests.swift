import Foundation
import Testing
@testable import NPGKit

/**
 Decoding of a boundary's `doorwaypriority`.

 The feed uses 0 to mean a shut door, but ``NPGArea/Boundary/Priority`` had no 0 and the decoder
 swallowed the resulting failure with `?? .primary`. A closed door therefore decoded as the *best*
 possible door, and wayfinding routed visitors straight through it. Any unrecognised value was
 promoted the same way.

 These checks pin down the three cases the decoder now distinguishes: recognised, absent, and
 present-but-unrecognised.
 */
@Suite("Doorway priority decoding")
struct DoorwayPriorityTests {

    /// A boundary as the feed publishes it, with `doorwaypriority` spelled by the caller.
    private func boundaryJSON(
        type: String = "doorway",
        priority: String? = "1"
    ) -> Data {
        let priorityField = priority.map { "\"doorwaypriority\":\($0)," } ?? ""
        let json = """
        {"id":1,"locationid":2,"dateadded":"2026-01-01","datemodified":"2026-01-01",
         "title":"Wall D","orientation":"north","priority":1,"width":120,"height":300,
         "boundarytype":"\(type)","doorwaylocationid":3,\(priorityField)"labels":[]}
        """
        return Data(json.utf8)
    }

    private func decodePriority(
        type: String = "doorway",
        priority: String?
    ) throws -> NPGArea.Boundary.Priority? {
        let boundary = try JSONDecoder.npgKit.decode(
            NPGArea.Boundary.self,
            from: boundaryJSON(type: type, priority: priority)
        )
        guard case .doorway(_, let decoded) = boundary.boundaryType else { return nil }
        return decoded
    }

    // MARK: - Recognised values

    @Test("A doorwaypriority of 0 decodes as closed")
    func zeroIsClosed() throws {
        #expect(try decodePriority(priority: "0") == .closed)
    }

    @Test(
        "Each recognised doorwaypriority decodes to its case",
        arguments: [
            ("0", NPGArea.Boundary.Priority.closed),
            ("1", .primary),
            ("2", .secondary),
            ("3", .tertiary),
            ("4", .wrongDirection)
        ]
    )
    func recognisedValues(rawValue: String, expected: NPGArea.Boundary.Priority) throws {
        #expect(try decodePriority(priority: rawValue) == expected)
    }

    /// Widths and heights arrive as strings in some payloads, so priorities are accepted either way.
    @Test("A doorwaypriority supplied as a string still decodes")
    func stringValue() throws {
        #expect(try decodePriority(priority: "\"0\"") == .closed)
        #expect(try decodePriority(priority: "\"2\"") == .secondary)
    }

    // MARK: - Absent values

    /**
     A door the feed has no opinion about stays `.primary`.

     16 of the boundaries in the wayfinding snapshot omit the key entirely, and they are ordinary
     doors, so this default has to survive the change.
     */
    @Test("An absent doorwaypriority stays primary")
    func absentIsPrimary() throws {
        #expect(try decodePriority(priority: nil) == .primary)
    }

    @Test("A null doorwaypriority stays primary")
    func nullIsPrimary() throws {
        #expect(try decodePriority(priority: "null") == .primary)
    }

    // MARK: - Unrecognised values

    /**
     An unrecognised value must not become the preferred door.

     This is the general form of the priority-0 bug: `?? .primary` promoted *any* value the enum
     didn't know to the best possible door. `.tertiary` keeps a stray value passable — so a room
     doesn't become unreachable because of a typo in the feed — without ever preferring it.
     */
    @Test("An unrecognised doorwaypriority falls back to tertiary", arguments: ["7", "-1", "\"abc\"", "true"])
    func unrecognisedIsTertiary(rawValue: String) throws {
        #expect(try decodePriority(priority: rawValue) == .tertiary)
    }

    // MARK: - The "closed doorway" boundary type

    /// The feed's other way of saying "shut" now agrees with a priority of 0.
    @Test("A closed doorway boundary type decodes as closed")
    func closedDoorwayType() throws {
        let boundary = try JSONDecoder.npgKit.decode(
            NPGArea.Boundary.self,
            from: boundaryJSON(type: "closed doorway", priority: nil)
        )
        guard case .doorway(let toOtherLocationID, let priority) = boundary.boundaryType else {
            Issue.record("Expected a doorway, got \(boundary.boundaryType)")
            return
        }
        #expect(priority == .closed)
        #expect(toOtherLocationID == nil, "A closed doorway leads nowhere")
    }

    // MARK: - Round trip

    @Test("A closed priority survives a round trip")
    func roundTrip() throws {
        let boundary = try JSONDecoder.npgKit.decode(
            NPGArea.Boundary.self,
            from: boundaryJSON(priority: "0")
        )
        let reencoded = try JSONEncoder.npgKit.encode(boundary)
        let decoded = try JSONDecoder.npgKit.decode(NPGArea.Boundary.self, from: reencoded)

        guard case .doorway(_, let priority) = decoded.boundaryType else {
            Issue.record("Expected a doorway, got \(decoded.boundaryType)")
            return
        }
        #expect(priority == .closed)
    }
}
