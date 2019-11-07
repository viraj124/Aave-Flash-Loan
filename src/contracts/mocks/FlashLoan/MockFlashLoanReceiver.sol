pragma solidity ^0.5.0;

import "../../../../node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol";
import "https://github.com/provable-things/ethereum-api/blob/master/provableAPI_0.5.sol";
import "../../flashloan/base/FlashLoanReceiverBase.sol";
import "../tokens/MintableERC20.sol";


contract MockFlashLoanReceiver is FlashLoanReceiverBase, usingProvable {

    using SafeMath for uint256;
    event ExecutedWithFail(address _reserve, uint256 _amount, uint256 _fee);
    event ExecutedWithSuccess(address _reserve, uint256 _amount, uint256 _fee);


    bool failExecution = false;
    string public tx; // for storing result of query

    constructor(ILendingPoolAddressesProvider _provider) FlashLoanReceiverBase(_provider)  public {
    }

    function setFailExecutionTransfer(bool _fail) public {
        failExecution = _fail;
    }

       function __callback(bytes32 myid, string result) private {
       if (msg.sender != provable_cbAddress()) revert();
       tx = result;
   }

    function executeOperation(
        address _reserve,
        uint256 _amount,
        uint256 _fee) external returns(uint256 returnedAmount) {
        //mint to this contract the specific amount
        MintableERC20 token = MintableERC20(_reserve);


        //check the contract has the specified balance
        require(_amount <= getBalanceInternal(address(this), _reserve), "Invalid balance for the contract");
        
        //BOT LOGIC
        //Calling trade api via oracalize 
        //todo for me currently hardcoded the variables
        provable_query("URL", "json(https://api.dex.ag/trade?from=ETH&to=DAI&fromAmount=1&dex=ag).tx"); //this returns the trade odetails now we would have to call the trade api from here.

        if(failExecution) {
            emit ExecutedWithFail(_reserve, _amount, _fee);
            //returns amount + fee, but does not transfer back funds
            return _amount.add(_fee);
        }

        //execution does not fail - mint tokens and return them to the _destination
        //note: if the reserve is eth, the mock contract must receive at least _fee ETH before calling executeOperation
        INetworkMetadataProvider dataProvider = INetworkMetadataProvider(addressesProvider.getNetworkMetadataProvider());

        if(_reserve != dataProvider.getEthereumAddress()) {
            token.mint(_fee);
        }
        //returning amount + fee to the destination
        transferFundsBackToPoolInternal(_reserve, _amount.add(_fee));
        emit ExecutedWithSuccess(_reserve, _amount, _fee);
        return _amount.add(_fee);

    }
}