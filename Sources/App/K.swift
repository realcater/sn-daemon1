
struct K {
    static let redTeam = 0
    static let blueTeam = 1
    static let spymaster = 0
    static let operatives = 1
    
    static let redCard = 0
    static let blueCard = 1
    static let greyCard = 2
    static let blackCard = 3
    
    static let redSpymaster = Player(team: redTeam, type: spymaster)
    static let blueSpymaster = Player(team: blueTeam, type: spymaster)
    static let redOperatives = Player(team: redTeam, type: operatives)
    static let blueOperatives = Player(team: blueTeam, type: operatives)

    // deviceRoles[deviceQty][indexBtnPressed] -> [Player]
    static let roles: [Int: [Int: [Player]]] = [
        1: [
            0: [redSpymaster, blueSpymaster, redOperatives, blueOperatives]
        ],
        2: [
            0: [redSpymaster, blueSpymaster],
            1: [redOperatives, blueOperatives]
        ],
        3: [
            0: [redSpymaster],
            1: [blueSpymaster],
            2: [redOperatives, blueOperatives]
        ],
        4: [
            0: [redSpymaster],
            1: [blueSpymaster],
            2: [redOperatives],
            3: [blueOperatives]
        ]
    ]
    static let testCards = [
        Card(word: "word1", color: K.redCard, _guessed: false),
        Card(word: "word2", color: K.blueCard, _guessed: false),
        Card(word: "word3", color: K.greyCard, _guessed: false)
    ]
}
