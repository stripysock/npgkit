import XCTest
import Combine
@testable import NPGKit

@available(iOS 15.0, *)
final class NPGKitTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()
    private let npgKit = NPGKit(dataSource: .production)
    
    func testArtworkRetrieval() {
        let artworkExpectation = XCTestExpectation(description: "Artwork loads successfully")
        
        npgKit.$artworks
            .receive(on: RunLoop.main)
            .sink { [npgKit] artwork in
                if !npgKit.artworks.isEmpty {
                    print("Haz \(artwork.count) artworks!")
                    artworkExpectation.fulfill()
                } else {
                    print("No artworks yet...")
                }
            }
            .store(in: &cancellables)
             
        Task {
            do {
                try await npgKit.refreshData()
                
            } catch {
                XCTFail(error.localizedDescription)
            }
        }
        
        wait(for: [artworkExpectation], timeout: 8)
    }
    
    func testArtworkSorting() {
        let artworkCountExpectation = XCTestExpectation(description: "More than one artwork is retrieved")
        let artworkSortExpectation = XCTestExpectation(description: "Artwork sorts successfully")
        
        npgKit.$artworks
            .receive(on: RunLoop.main)
            .sink { [npgKit] artwork in
                if !npgKit.artworks.isEmpty {
                    
                    if npgKit.artworks.count > 1 {
                        print("Haz \(artwork.count) artworks!")
                        artworkCountExpectation.fulfill()
                    } else {
                        XCTFail("Didn't retrieve enough artworks")
                    }
                    
                    let sorted = npgKit.artworks.sorted()
                    
                    // visually inspect sorted items with latest sorting logic
                    print(sorted[0])
                    print(sorted[1])
                    
                    artworkSortExpectation.fulfill()
                    
                    
                } else {
                    print("No artworks yet...")
                }
            }
            .store(in: &cancellables)
             
        Task {
            do {
                try await npgKit.refreshData()
                
            } catch {
                XCTFail(error.localizedDescription)
            }
        }
        
        wait(for: [artworkCountExpectation,artworkSortExpectation], timeout: 8)
    }
    
    func testTourRetrieval() {
        let tourExpectation = XCTestExpectation(description: "Tours load successfully")
        
        npgKit.$tours
            .receive(on: RunLoop.main)
            .sink { _ in
                // Tours may be empty in production
                print("Haz tours!")
                tourExpectation.fulfill()
                
            }
            .store(in: &cancellables)
             
        Task {
            do {
                try await npgKit.refreshData()
                
            } catch {
                XCTFail(error.localizedDescription)
            }
        }
        
        wait(for: [tourExpectation], timeout: 8)
    }
    
    func testLocationRetrieval() {
        let beaconExpectation = XCTestExpectation(description: "Beacons load successfully")
        let areaExpectation = XCTestExpectation(description: "Areas load successfully")
        let locationExpectation = XCTestExpectation(description: "Locations load successfully")
        
        npgKit.$areas
            .receive(on: RunLoop.main)
            .sink { [npgKit] areas in
                if !npgKit.areas.isEmpty {
                    print("Haz areas!")
                    areaExpectation.fulfill()
                } else {
                    print("No areas yet...")
                }
            }
            .store(in: &cancellables)
        
        npgKit.$locations
            .receive(on: RunLoop.main)
            .sink { [npgKit] locations in
                if !npgKit.locations.isEmpty {
                    print("Haz locations!")
                    locationExpectation.fulfill()
                } else {
                    print("No locations yet...")
                }
            }
            .store(in: &cancellables)
        
        npgKit.$beacons
            .receive(on: RunLoop.main)
            .sink { [npgKit] beacons in
                if !npgKit.beacons.isEmpty {
                    print("Haz beacons!")
                    beaconExpectation.fulfill()
                } else {
                    print("No beacons yet...")
                }
            }
            .store(in: &cancellables)
        
        Task {
            do {
                try await npgKit.refreshData()
                
            } catch {
                XCTFail(error.localizedDescription)
            }
        }
        
        wait(for: [beaconExpectation, areaExpectation, locationExpectation], timeout: 8)
    }
    
    func testEntityRetrieval() {
        let entityExpectation = XCTestExpectation(description: "Entities load successfully")
        
        npgKit.$entities
            .receive(on: RunLoop.main)
            .sink { [npgKit] entities in
                if !npgKit.entities.isEmpty {
                    print("Haz \(entities.count) entities!")
                    
                    // Inspect entities
                    if let inspectable = entities.first(where: { $0.id == 9029 }) {
                        print(inspectable)
                    }
                    
                    entityExpectation.fulfill()
                } else {
                    print("No entities yet...")
                }
            }
            .store(in: &cancellables)
             
        Task {
            do {
                try await npgKit.refreshData()
                
            } catch {
                XCTFail(error.localizedDescription)
            }
        }
        
        wait(for: [entityExpectation], timeout: 8)
    }
    
    func testEntityEncoding() {
        let expectation = XCTestExpectation(description: "Entities encoded successfully.")
        
        let humanEntity = NPGEntity(id: 8459,
                                    dateModified: Date(),
                                    displayName: "Hugh Jackman AC",
                                    simpleName: "Hugh Jackman",
                                    givenNames: ["Hugh"],
                                    familyNames: ["Jackman"],
                                    text: [
                                        .init(type: .biography,
                                              content: "<p>Hugh Jackman AC (b. 1968) is the ultimate triple threat â€“ actor, singer and dancer. Best known for his role as Wolverine in the <EM>X-Men</EM> movies, Jackman was born to British parents in Sydney and took up acting as a hobby while a student at Knox Grammar in the 1980s. He gained a BA in Communications from UTS in 1991, but afterwards undertook formal study in drama at the Actors' Centre, Sydney. Jackman turned down a role in <EM>Neighbours</EM> to focus on honing his skills further at Perth's Western Australian Academy of Performing Arts. On graduating in 1994 he scored a role in the ABC television drama <EM>Correlli</EM> opposite Deborra-Lee Furness, who he married the following year, and in musical productions in Melbourne. He made his West End debut in 1998 in the Royal National Theatreâ€™s <EM>Oklahoma!</EM> In 2000, having appeared in various Australian television dramas including <EM>Blue Heelers</EM>, Jackman gave his first performance as Wolverine in the film adaptation of Marvel Comics' <EM>X-Men</EM>, and reprised the role in several sequels and spin-offs between 2003 and 2017. During the same period, he appeared in numerous other films: among them <EM>Kate and Leopold</EM> (2001), for which he earned a Golden Globe nomination; <EM>Van Helsing</EM> (2004); <EM>The Prestige</EM> (2006); Woody Allen's <EM>Scoop</EM> (2006); the Baz Luhrmann epic <EM>Australia</EM> (2008) and the PT Barnum biopic <EM>The Greatest Showman</EM> (2017), for which he won a Grammy; and voiced characters in the animated features <EM>Happy Feet</EM> (2006), <EM>Flushed Away</EM> (2006) and <EM>Rise of the Guardians</EM> (2012). In 2013, he received Oscar and BAFTA nominations and won a Best Actor Golden Globe for his lead role in <EM>Les MisÃ©rables</EM>. Meanwhile, he had forged a towering reputation on Broadway, in particular for his Tony Award-winning role as performer Peter Allen in <EM>The Boy from Oz</EM> (2003â€“2004). In late 2015, Jackman toured Australia with his show <EM>Broadway to Oz</EM>, in which he reprised various musical numbers, backed by a 150-piece orchestra; and during 2019 he undertook his first world tour with <EM>The Man. The Music. The Show.</EM> Named a Companion of the Order of Australia in June 2019, Jackman has lent his profile and his voice to several charitable and philanthropic causes including World Vision, Global Poverty Project and Broadway Cares/Equity Fights AIDS.</p>",
                                              priority: 1)
                                    ],
                                    audio: [
                                        .init(id: 329,
                                              dateModified: Date(),
                                              priority: 1,
                                              audioContext: .intheirownwords,
                                              title: "Vincent Fantauzzo on Hugh Jackman",
                                              duration: "1 minute 24 seconds",
                                              transcript: "You know, I'm highly dyslexic and my way of learning was to directly interact with people and hang out with them and I found that once I did a few portraits, I thought, wow, this is like a licence to stalk people, you know, people are really open and want to be a part of it and I get to know people. And when you get to know people, you learn so much from them. So I think I just became interested in people.\n\nSo Hugh asked for me to do his portrait. We actually share a lot of mutual friends, but you never know, itâ€™s like going on a blind date with someone, you meet up with them and you actually have a real great connection. Photographyâ€™s a big part of the portrait to me and I normally film people and just base the portrait on all my images and film so I can see those moments. Hughâ€™s son is very into art and quite creative and he wanted to bring his son along for the photo shoot. So I had a plan up my sleeve that I was gonna ask his son to talk to his Dad and pull the trigger on a camera. And then the virus hit. And then Hugh called me up the night before he was coming to do photographs at my house and said, â€˜If I donâ€™t jump on a plane tonight then Iâ€™m gonna get shut out of the U.S.â€™ And his family was there, so they had to fly off and that didnâ€™t happen. And then I made a video for Deb, Hughâ€™s wife, on how to shoot the portrait and I think because Deb took the pictures thereâ€™s this beautiful look in â€¦ The paintingâ€™s quite different to the photograph because I made it black and white and added my own touch to it, but thereâ€™s a look in Hughâ€™s eyes and you can tell itâ€™s a conversation with someone that he knows and trusts, itâ€™s not a GQ photo shoot which is probably great images as well. But I didnâ€™t want that; I wanted that intimacy we spoke about. So I think thereâ€™s a love and intimacy that I think Iâ€™ve got.",
                                              url: URL(string: "https://www.portrait.gov.au/files/e/a/3/a/a329.mp3")!)
                                    ],
                                    artworkAsSubjectIDs: [1484],
                                    artworkAsArtistIDs: [])
        
        let groupEntity = NPGEntity(id: 8380,
                                    dateModified: Date(),
                                    displayName: "The Huxleys",
                                    text: [
                                        .init(type: .biography, content: "<p>Will Huxley grew up in the suburbs of Perth, Western Australia, and Garrett Huxley was raised on the Gold Coast, Queensland. After university, where they both studied photography â€“ Will at Edith Cowan University and Garrett at the Queensland College of Art â€“ the artists gravitated to Melbourne where they met in 2006. The pair soon began to collaborate as The Huxleys, combining their separate practices of photography, filmmaking and costume design, with performance as a key element. Inspired by the attention-grabbing and the outrageous, the artists embrace the glamourous, the absurd and the provocative and in doing so challenge convention; the Huxleys persuade their audience to consider notions of gender, social mores and non-conformity. The artists have become part of a contemporary cohort of collaborating duos, which includes the British pair Gilbert and George, and Australia's Charles Green and Lyndal Brown. The Huxleys continue to be in demand across the country and internationally, invited to work at the Art Gallery of South Australia, Art Gallery of Western Australia, Museum of Brisbane, National Gallery of Victoria, Art Gallery of New South Wales, Heide Museum of Modern Art, Arts Centre Melbourne, Australian Centre for the Moving Image, the Mona Foma festival in Tasmania and Sydney Contemporary. They were the inaugural 'Disrupters in Residence' at HOTA on the Gold Coast, and were included in a select group of Australian artists invited to participate in the City of Melbourne's UPTOWN. Internationally they have performed and exhibited in London, Hong Kong, Tokyo, Moscow and Berlin.</p> ", priority: 1)
                                    ],
                                    audio: [],
                                    artworkAsSubjectIDs: [2210, 2218],
                                    artworkAsArtistIDs: [2210, 2218])
        
        let encoder = JSONEncoder()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        encoder.dateEncodingStrategy = .formatted(dateFormatter)
        
        do {
            let data = try encoder.encode([humanEntity, groupEntity])
            if let json = String(data: data, encoding: .utf8) {
                print(json)
                expectation.fulfill()
                
            } else {
                XCTFail("Couldn't convert data to string.")
            }
        } catch {
            XCTFail(error.localizedDescription)
        }
        
        wait(for: [expectation], timeout: 8)
    }
}
