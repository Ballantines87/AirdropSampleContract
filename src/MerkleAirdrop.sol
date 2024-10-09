// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// Layout of Contract:
// version
// imports
// interfaces, libraries, contracts
// errors
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract MerkleAirdrop {
    // some list of addresses
    // allow someone in the list to claim tokens

    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/

    error MerkleAirdrop_InvalidProof();
    error MerkleAirdrop_AccountHasAlreadyClaimed();

    /*//////////////////////////////////////////////////////////////
                           TYPE DECLARATIONS
    //////////////////////////////////////////////////////////////*/

    using SafeERC20 for IERC20;

    /*//////////////////////////////////////////////////////////////
                           STATE VARIABLES
    //////////////////////////////////////////////////////////////*/
    bytes32 private immutable i_merkleRoot;
    IERC20 private immutable i_airdropToken;
    mapping(address claimer => bool claimed) s_addressesWhichHaveClaimed;

    /*//////////////////////////////////////////////////////////////
                           EVENTS
    //////////////////////////////////////////////////////////////*/

    event TokensMinted(address indexed accountThatClaimed, uint256 indexed amountClaimed);

    // merkle proofs to check if some data is in some group of data

    constructor(bytes32 merkleRoot, IERC20 airdropToken) {
        i_merkleRoot = merkleRoot;
        i_airdropToken = airdropToken;
    }

    /*//////////////////////////////////////////////////////////////
                               FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function claim(address account, uint256 amount, bytes32[] calldata merkleProof) external {
        // calculate using the account and the amount, the hash -> which is going to be the leaf node

        /*
        In summary, the line of code below:
            - abi.encode(x, y): Encodes x and y into bytes - abi.encode() adds type information and padding.
            - keccak256(...): Hashes that encoded data -> the output is a bytes32 hash.
            - bytes.concat(...): Converts bytes32 to bytes.
            - Final keccak256(...): Re-hashes the concatenated byte -> the output is again a bytes32 hash.
        */
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(account, amount))));
        if (s_addressesWhichHaveClaimed[account]) {
            revert MerkleAirdrop_AccountHasAlreadyClaimed();
        }
        if (!MerkleProof.verify(merkleProof, i_merkleRoot, leaf)) {
            revert MerkleAirdrop_InvalidProof();
        }
        s_addressesWhichHaveClaimed[account] = true;
        emit TokensMinted(account, amount);
        i_airdropToken.safeTransfer(account, amount);
    }

    function getMerkleRoot() public view returns (bytes32) {
        return i_merkleRoot;
    }

    function getAirdropToken() public view returns (IERC20) {
        return i_airdropToken;
    }
}
