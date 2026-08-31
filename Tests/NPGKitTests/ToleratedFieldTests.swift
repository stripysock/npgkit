import Foundation
import Testing
@testable import NPGKit

/**
 Decoding of records that omit optional collections.

 The `ondisplaylive` endpoints don't emit every key the newer `ondisplaywalltest` ones do — as at
 August 2026 they omit `adjacentareas` on areas, and `adjacentlocations` and `boundaries` on
 locations. These types used to rely on Swift's synthesised decoder, which treats every non-optional
 property as mandatory, so each of those records failed to decode.

 `NPGData` wraps every element in ``FailableDecodable``, so such failures were *silent*: the bad
 records were dropped and the caller received a shorter array — or an empty one — with no error. That
 is the behaviour these checks exist to prevent.
 */
@Suite("Records omitting optional collections")
struct ToleratedFieldTests {

    // MARK: - Areas

    /// An area as `ondisplaylive` publishes it: no `adjacentareas`.
    @Test("An area without adjacentareas decodes")
    func areaWithoutAdjacentAreas() throws {
        let json = """
        {"id":57,"datemodified":"2026-01-01","dateadded":"2026-01-01","title":"Welcome",
         "subtitle":"","beaconids":[17],"priority":1,"locations":[92,234],"labels":[],"audio":[]}
        """
        let area = try JSONDecoder.npgKit.decode(NPGArea.self, from: Data(json.utf8))

        #expect(area.id == 57)
        #expect(area.title == "Welcome")
        #expect(area.locationIDs == [92, 234])
        #expect(area.adjacentAreas.isEmpty)
        #expect(area.externalCoordinates == nil)
    }

    /// Every collection absent at once — the record is still usable.
    @Test("An area with no collections at all decodes")
    func areaWithNoCollections() throws {
        let json = """
        {"id":1,"datemodified":"2026-01-01","dateadded":"2026-01-01","title":"Bare","priority":1}
        """
        let area = try JSONDecoder.npgKit.decode(NPGArea.self, from: Data(json.utf8))

        #expect(area.beaconIDs.isEmpty)
        #expect(area.locationIDs.isEmpty)
        #expect(area.artworkIDs.isEmpty)
        #expect(area.adjacentAreas.isEmpty)
    }

    /// A genuinely unusable record must still fail — we don't want to invent a title or an ID.
    @Test("An area missing a scalar still fails")
    func areaMissingScalarFails() {
        let json = """
        {"id":1,"datemodified":"2026-01-01","priority":1}
        """
        #expect(throws: (any Error).self) {
            try JSONDecoder.npgKit.decode(NPGArea.self, from: Data(json.utf8))
        }
    }

    // MARK: - Locations

    /// A location as `ondisplaylive` publishes it: no `adjacentlocations`, no `boundaries`.
    @Test("A location without adjacentlocations or boundaries decodes")
    func locationWithoutWayfindingFields() throws {
        let json = """
        {"id":239,"areaid":57,"datemodified":"2026-01-01","dateadded":"2026-01-01",
         "title":"Lockers","subtitle":"","content":"","priority":6,"labels":[],"audio":[]}
        """
        let location = try JSONDecoder.npgKit.decode(NPGArea.Location.self, from: Data(json.utf8))

        #expect(location.id == 239)
        #expect(location.areaID == 57)
        #expect(location.title == "Lockers")
        #expect(location.boundaryIDs.isEmpty)
        #expect(location.adjacentLocations.isEmpty)
    }

    /**
     A location's `content` must survive the round trip.

     `content` was missing from `CodingKeys`, so entrance-label text was silently discarded — it
     decoded as nil even when the feed supplied it.
     */
    @Test("A location's content is decoded")
    func locationContentIsDecoded() throws {
        let json = """
        {"id":1,"areaid":2,"datemodified":"2026-01-01","dateadded":"2026-01-01","title":"Room",
         "content":"Welcome to this gallery.","priority":1,"labels":[],"audio":[],
         "boundaries":[],"adjacentlocations":[]}
        """
        let location = try JSONDecoder.npgKit.decode(NPGArea.Location.self, from: Data(json.utf8))
        #expect(location.content == "Welcome to this gallery.")
    }

    // MARK: - Other synthesised types

    @Test("A beacon without its ID lists decodes")
    func beaconWithoutLists() throws {
        let json = """
        {"id":1,"uuid":"A4F04E94-A280-A280-A280-FAA280280280","major":1,"minor":28,
         "title":"Foyer","datemodified":"2026-01-01","dateadded":"2026-01-01"}
        """
        let beacon = try JSONDecoder.npgKit.decode(NPGBeacon.self, from: Data(json.utf8))

        #expect(beacon.minor == 28)
        #expect(beacon.areaIDs.isEmpty)
        #expect(beacon.locationIDs.isEmpty)
        #expect(beacon.artworkIDs.isEmpty)
    }

    @Test("A tour without audio or stops decodes")
    func tourWithoutCollections() throws {
        let json = """
        {"id":1,"datemodified":"2026-01-01","title":"Highlights","priority":1}
        """
        let tour = try JSONDecoder.npgKit.decode(NPGTour.self, from: Data(json.utf8))

        #expect(tour.title == "Highlights")
        #expect(tour.audio.isEmpty)
        #expect(tour.tourStops.isEmpty)
    }

    @Test("An entity without its collections decodes")
    func entityWithoutCollections() throws {
        let json = """
        {"id":1,"datemodified":"2026-01-01","displayname":"Hugh Jackman AC"}
        """
        let entity = try JSONDecoder.npgKit.decode(NPGEntity.self, from: Data(json.utf8))

        #expect(entity.displayName == "Hugh Jackman AC")
        #expect(entity.text.isEmpty)
        #expect(entity.audio.isEmpty)
        #expect(entity.artworkAsSubjectIDs.isEmpty)
        #expect(entity.artworkAsArtistIDs.isEmpty)
    }

    // MARK: - The silent-drop path

    /**
     The reason the previous behaviour was so easy to miss.

     `NPGData` wraps each element in ``FailableDecodable``, so a record that fails to decode is
     dropped and the caller sees a shorter list rather than an error. Before these decoders existed,
     a production `/areas` payload produced an **empty** array with nothing but a log line. This
     asserts the whole payload now survives.
     */
    @Test("A production-shaped payload survives NPGData's per-record decoding")
    func productionPayloadIsNotSilentlyDropped() throws {
        let payload = """
        {"areas":[
          {"id":57,"datemodified":"2026-01-01","dateadded":"2026-01-01","title":"Welcome",
           "subtitle":"","beaconids":[17],"priority":1,"locations":[92],"labels":[],"audio":[]},
          {"id":43,"datemodified":"2026-01-01","dateadded":"2026-01-01","title":"Collection focus",
           "subtitle":"","beaconids":[],"priority":3,"locations":[89],"labels":[],"audio":[]}
        ],
         "locations":[
          {"id":92,"areaid":57,"datemodified":"2026-01-01","dateadded":"2026-01-01",
           "title":"Forecourt","subtitle":"","content":"","priority":1,"labels":[],"audio":[]}
        ]}
        """
        let data = try JSONDecoder.npgKit.decode(NPGData.self, from: Data(payload.utf8))

        let areas = data.areas ?? []
        #expect(areas.count == 2)
        #expect(areas.compactMap(\.base).count == 2, "No area should be silently dropped")
        #expect(areas.compactMap(\.error).isEmpty)

        let locations = data.locations ?? []
        #expect(locations.compactMap(\.base).count == 1, "No location should be silently dropped")
        #expect(locations.compactMap(\.error).isEmpty)
    }

    /// `FailableDecodable` should still isolate a genuinely broken record rather than failing the
    /// whole payload — that behaviour is worth keeping.
    @Test("One unusable record doesn't take the payload with it")
    func oneBadRecordIsIsolated() throws {
        let payload = """
        {"areas":[
          {"id":57,"datemodified":"2026-01-01","dateadded":"2026-01-01","title":"Good",
           "priority":1,"labels":[]},
          {"id":99,"datemodified":"2026-01-01","priority":1}
        ]}
        """
        let data = try JSONDecoder.npgKit.decode(NPGData.self, from: Data(payload.utf8))
        let areas = data.areas ?? []

        #expect(areas.compactMap(\.base).count == 1)
        #expect(areas.compactMap(\.error).count == 1)
        #expect(areas.compactMap(\.base).first?.title == "Good")
    }
}
