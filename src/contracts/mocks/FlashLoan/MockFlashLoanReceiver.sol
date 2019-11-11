pragma solidity ^0.5.5;

import "../../flashloan/base/FlashLoanReceiverBase.sol";
import "../tokens/MintableERC20.sol";
import "./KyberNetworkProxyInterface.sol";
import "./SimpleNetworkInterface.sol";
import "./UniswapExchange.sol";


contract MockFlashLoanReceiver is FlashLoanReceiverBase {

    using SafeMath for uint256;
    event ExecutedWithFail(address _reserve, uint256 _amount, uint256 _fee);
    event ExecutedWithSuccess(address _reserve, uint256 _amount, uint256 _fee);

    ERC20 constant internal ETH_TOKEN_ADDRESS = ERC20(0x00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee);


    event trademade(uint256 tokens, uint256 _amount);

    constructor(ILendingPoolAddressesProvider _provider) FlashLoanReceiverBase(_provider)  public {
    }



    function executeOperation(
        address _reserve,
        uint256 _amount,
        uint256 _fee) external returns(uint256 returnedAmount) {
        //mint to this contract the specific amount
        MintableERC20 token = MintableERC20(_reserve);

        uint minConversionRate;


        //check the contract has the specified balance
        require(_amount <= getBalanceInternal(address(this), _reserve), "Invalid balance for the contract");

        //BOT LOGIC
        token.approve(0xB4ca10f43caF503b7Aa0a77757B99c78212D6b92, _amount);
        // Exchange for token -> eth
        UniswapExchange followerUniSwapExchange = UniswapExchange(0xc4f86802c76df98079f45a60ba906bdf86ad90c1);

        uint256 DEADLINE = block.timestamp + 200;
        // Swap token -> Eth
        uint256 eth_bought = followerUniSwapExchange.tokenToEthSwapInput(_amount, 0, DEADLINE);

        // Exchange for Eth -> token
        //used to get minimum conversion rate
        KyberNetworkProxyInterface kyberProxy = KyberNetworkProxyInterface(0x692f391bCc85cefCe8C237C01e1f636BbD70EA4D);

        (minConversionRate,) = kyberProxy.getExpectedRate(ETH_TOKEN_ADDRESS, token, eth_bought);

        //used to do the actual swap
        SimpleNetworkInterface swapEth = SimpleNetworkInterface(0x692f391bCc85cefCe8C237C01e1f636BbD70EA4D);

        // Swap Eth -> Token
        uint token_bought = swapEth.swapEtherToToken.value(eth_bought)(token, minConversionRate); //first parameter is the token we wnat to recieve which will always be DAI and 2nd is conversion rate, which i just substituting as _fee for now.

        emit trademade(token_bought, _amount);
        //returning amount + fee to the destination
        transferFundsBackToPoolInternal(_reserve, _amount.add(_fee));
        emit ExecutedWithSuccess(_reserve, _amount, _fee);
        return _amount.add(_fee);

    }
}
