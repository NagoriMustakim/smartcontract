// https://mumbai.polygonscan.com/address/0xe7cf857db6916993f386e74dde331156f5b25f84
// https://testnets.opensea.io/collection/pretty-awesome-words-8

pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./Base64.sol";

contract PrettyAwesomeWords is ERC721Enumerable, Ownable {
    using Strings for uint256;

    string[] public wordsValues = [
        "accomplish",
        "accepted",
        "absolutely",
        "admire",
        "achievement",
        "active",
        "adorable",
        "affirmative",
        "appealing",
        "approve",
        "amazing",
        "awesome",
        "beautiful",
        "believe",
        "beneficial",
        "bliss",
        "brave",
        "brilliant",
        "calm",
        "celebrated",
        "champion",
        "charming",
        "congratulation",
        "cool",
        "courageous",
        "creative",
        "dazzling",
        "delightful",
        "divine",
        "effortless",
        "electrifying",
        "elegant",
        "enchanting",
        "energetic",
        "enthusiastic",
        "excellent",
        "exciting",
        "exquisite",
        "fabulous",
        "fantastic",
        "fine",
        "fortunate",
        "friendly",
        "fun",
        "funny",
        "generous",
        "giving",
        "great",
        "happy",
        "harmonious",
        "healthy",
        "heavenly",
        "honest",
        "honorable",
        "impressive",
        "independent",
        "innovative",
        "intelligent",
        "intuitive",
        "kind",
        "knowledgeable",
        "legendary",
        "lucky",
        "lovely",
        "marvelous",
        "motivating",
        "nice",
        "perfect",
        "phenomenal",
        "popular",
        "positive",
        "productive",
        "refreshing",
        "remarkable",
        "skillful",
        "sparkling",
        "stunning",
        "successful",
        "supporting",
        "terrific",
        "tranquil",
        "trusting",
        "vibrant",
        "wholesome",
        "worthy",
        "wonderful"
    ];

    struct Word {
        string name;
        string description;
        string bgHue;
        string textHue;
        string value;
    }

    mapping(uint256 => Word) public words;

    constructor() ERC721("Pretty Awesome Words", "PWA") {}

    // public
    function mint() public payable {
        uint256 supply = totalSupply();
        require(supply + 1 <= 1000);

        Word memory newWord = Word(
            string(abi.encodePacked("PWA #", uint256(supply + 1).toString())),
            "Pretty Awesome Words are all you need to feel good. These NFTs are there to inspire and uplift your spirit.",
            randomNum(361, block.difficulty, supply).toString(),
            randomNum(361, block.timestamp, supply).toString(),
            wordsValues[randomNum(wordsValues.length, block.difficulty, supply)]
        );

        if (msg.sender != owner()) {
            require(msg.value >= 0.0005 ether);
        }

        words[supply + 1] = newWord;
        _safeMint(msg.sender, supply + 1);
    }

    function randomNum(
        uint256 _mod,
        uint256 _seed,
        uint256 _salt
    ) public view returns (uint256) {
        uint256 num = uint256(
            keccak256(
                abi.encodePacked(block.timestamp, msg.sender, _seed, _salt)
            )
        ) % _mod;
        return num;
    }

    function buildImage(uint256 _tokenId) public view returns (string memory) {
        Word memory currentWord = words[_tokenId];
        return
            Base64.encode(
                bytes(
                    abi.encodePacked(
                        '<svg width="500" height="500" xmlns="http://www.w3.org/2000/svg">',
                        '<rect height="500" width="500" fill="hsl(',
                        currentWord.bgHue,
                        ', 50%, 25%)"/>',
                        '<text x="50%" y="50%" dominant-baseline="middle" fill="hsl(',
                        currentWord.textHue,
                        ', 100%, 80%)" text-anchor="middle" font-size="41">',
                        currentWord.value,
                        "</text>",
                        "</svg>"
                    )
                )
            );
    }

    function buildMetadata(uint256 _tokenId)
        public
        view
        returns (string memory)
    {
        Word memory currentWord = words[_tokenId];
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name":"',
                                currentWord.name,
                                '", "description":"',
                                currentWord.description,
                                '", "image": "',
                                "data:image/svg+xml;base64,",
                                buildImage(_tokenId),
                                '"}'
                            )
                        )
                    )
                )
            );
    }

    function tokenURI(uint256 _tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(_tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );
        return buildMetadata(_tokenId);
    }

    function withdraw() public payable onlyOwner {
        (bool os, ) = payable(owner()).call{value: address(this).balance}("");
        require(os);
    }
}