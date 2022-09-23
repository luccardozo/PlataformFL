import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";
import "hardhat/console.sol";

import "./DataTypes.sol";
import "./JobContract.sol";

contract Requester {
    address public owner;                           // Endereço da carteira do Trainer
    address public DAOManager;                      // Manager é o endereço do contrato que faz o gerenciamento da DAO
    DataTypes.Evaluation[]  public  evaluations;    // List of received evaluation


    uint256[] internal pendingOffersIDs;      
    mapping(uint256 => DataTypes.Offer) private pendingOffers; //<offerID, Offer> Ofertas de trabalho que estão aguardando resposta.

    address[] internal jobsAddress;
    mapping(address => JobContract) private jobContracts;   // Contratos de trabalho 

    modifier onlyOwner {
      require(msg.sender == owner,  "Only owner");
      _;
    }

    modifier onlyDAO {
      require(msg.sender == DAOManager, "Only DAO");
      _;
    }   

    constructor(address ownerAddress) {
        DAOManager    = msg.sender;
        owner         = ownerAddress;
        
        console.log("Requester: DAO =", DAOManager, "Owner=", owner);
    }

    function newContract(JobContract newJobContract) external onlyDAO {
        console.log("newContract: ", owner);
        
        newJobContract.LogContract();
        insertContract(newJobContract);
    }

    function insertContract(JobContract newJobContract) internal {
        jobContracts[address(newJobContract)] = newJobContract;
        jobsAddress.push(address(newJobContract));

        console.log("insertContract:" ,address(newJobContract), " Count jobContracts =", jobsAddress.length);
    }

}