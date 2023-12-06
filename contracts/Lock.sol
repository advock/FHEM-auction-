// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

// Uncomment this line to use console.log
// import "hardhat/console.sol";
import "node_modules/fhevm/lib/TFHE.sol";

contract NFTauction {
    enum AuctionStatus {
        Active,
        Ended
    }

    mapping(address => mapping(uint256 => AuctionStatus)) public auctionStatus;
    // nft add => tokenid => auction status
    mapping(address => mapping(uint256 => uint256)) public EntryFee;
    // nft add => tokenid => Entry fees
    mapping(address => mapping(uint256 => uint256)) public EndTime;
    // nft add => tokeni => end time

    mapping(address => mapping(address => mapping(uint256 => euint32)))
        public Bid;
    // bidr add => nft add => tokenid => bit amount

    mapping(address => mapping(uint256 => address[])) public bids;

    // nft add => tokenid => all the address that have bid

    mapping(address => mapping(uint256 => address)) public winner;

    // nft add => token id => bid amount

    // mft add => tokenid = > all biders

    function createAuction(
        address nftAddress,
        uint256 tokenId,
        uint256 auctionEndTime,
        uint256 entryFee
    ) public {
        auctionStatus[nftAddress][tokenId] = AuctionStatus.Active;
        EntryFee[nftAddress][tokenId] = entryFee;
        EndTime[nftAddress][tokenId] = auctionEndTime;
    }

    function bid(
        address nftAddress,
        uint256 tokenId,
        euint32 bid
    ) public payable {
        require(block.timestamp < EndTime[nftAddress][tokenId]);
        require(msg.value >= EntryFee[nftAddress][tokenId]);

        Bid[msg.sender][nftAddress][tokenId] = bid;

        address[] storage oders = bids[nftAddress][tokenId];

        oders.push(msg.sender);

        bids[nftAddress][tokenId] = oders;
    }

    function endLottery(address nftAddress, uint256 tokenId) public {
        require(block.timestamp > EndTime[nftAddress][tokenId]);
        auctionStatus[nftAddress][tokenId] = AuctionStatus.Ended;
    }

    function getWinner(address nftAddress, uint256 tokenId) public {
        endLottery(nftAddress, tokenId);
        euint32 maxBid;
        address maxBider;

        address[] storage orders = bids[nftAddress][tokenId];

        for (uint256 i = 0; i < orders.length; i++) {
            euint32 bitAmount = Bid[orders[i]][nftAddress][tokenId];

            bool result = TFHE.g(TFHE.gt(maxBid, bitAmount));

            if (result) {
                maxBider = orders[i];
            }
        }

        winner[nftAddress][tokenId] = maxBider;
    }
}
