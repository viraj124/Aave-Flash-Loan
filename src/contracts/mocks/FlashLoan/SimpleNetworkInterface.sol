pragma solidity ^0.5.5;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";

/// @title simple interface for Kyber Network
interface SimpleNetworkInterface {
    function swapTokenToToken(ERC20 src, uint srcAmount, ERC20 dest, uint minConversionRate) external returns(uint);
    function swapEtherToToken(ERC20 token, uint minConversionRate) external payable returns(uint);
    function swapTokenToEther(ERC20 token, uint srcAmount, uint minConversionRate) external returns(uint);
}
