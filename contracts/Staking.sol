//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

library SafeTokenTransfer {
    function approve(address token, address reciever, uint256 value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x095ea7b3, reciever, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "SafeTokenTransfer: APPROVE_FAILED"
        );
    }

    function transfer(address token, address reciever, uint256 value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0xa9059cbb, reciever, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "SafeTokenTransfer: TRANSFER_FAILED"
        );
    }

    function transferFrom(
        address token,
        address spender,
        address reciever,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x23b872dd, spender, reciever, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "SafeTokenTransfer: TRANSFER_FROM_FAILED"
        );
    }

    function transferETH(address reciever, uint256 value) internal {
        (bool success, ) = reciever.call{value: value}(new bytes(0));
        require(success, "SafeTokenTransfer: ETH_TRANSFER_FAILED");
    }
}
contract Staking {
    struct Data {
        uint256 Amount;
        uint256 Blocknum;
    }
    address public immutable Token;
    mapping(address => mapping(uint256 => Data)) public userRewards;
    uint256 public stakeID;

    constructor(address token) {
        Token = token;
    }

    function stake(uint256 amount) external returns (uint256) {
        SafeTokenTransfer.transferFrom(
            Token,
            msg.sender,
            address(this),
            amount
        );
        stakeID++;
        userRewards[msg.sender][stakeID] = Data(amount, block.number);
        return stakeID;
    }

    function withdrawStake(uint256[] calldata stakeIDs) external {
        uint256 amount = calculate(stakeIDs); // check effects interaction pattern implemented
        SafeTokenTransfer.transfer(Token, msg.sender, amount);
    }

    function calculate(uint256[] memory IDs) internal returns (uint256) {
        uint256 rewards;
        uint256 totalAmt;
        for (uint256 i = 0; i < IDs.length; i++) {
            Data memory data = userRewards[msg.sender][IDs[i]]; // saving gas
            uint256 _value = block.number - data.Blocknum;
            rewards += (data.Amount * _value);
            totalAmt += data.Amount;
            delete userRewards[msg.sender][IDs[i]];
        }
        return (rewards + totalAmt);
    }

    function getRewards(uint[] memory IDs) external view returns (uint256) {
        uint256 rewards;
        for (uint256 i = 0; i < IDs.length; i++) {
            Data memory data = userRewards[msg.sender][IDs[i]];
            uint256 _value = block.number - data.Blocknum;
            rewards += (data.Amount * _value);
        }
        return (rewards);
    }
}
