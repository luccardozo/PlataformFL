import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";
import "hardhat/console.sol";
import "./DataTypes.sol";
import "./JobContract.sol";

contract Trainer {
    string   public      description;   // Descrição texto livre do treinador
    string[] public      tags;          // Lista de tags do treinador.
    int      public      rating;                     //TODO: sum(evaluations[])/count(evaluations) 
    DataTypes.Evaluation[]  public  evaluations;    // List of received evaluation
    DataTypes.Specification public  specification;  // Specifications of the trainer.
    string publick dataPreviewCID;
   
    uint256[] internal pendingOffersIDs;      
    mapping(uint256 => DataTypes.Offer) private pendingOffers; //<offerID, Offer> Ofertas de trabalho que o treinador tem.

    address[] internal jobsAddress;
    mapping(address => JobContract) private jobContracts;       // Trabalhos atuais do treinador
    
    address public owner;                           // Endereço da carteira do Trainer
    address public DAO;                      // DAO é o endereço do contrato que faz o gerenciamento da DAO
    
    constructor(address ownerAddress, string memory _description, DataTypes.Specification memory _specification) {
        DAO    = msg.sender;
        owner         = ownerAddress;
        description   = _description;
        specification = _specification;
        rating        = 10; //Todos treinadores começam com nota maxima

        console.log("Trainer: DAO =", DAO, "Owner=", owner);
    }    

    modifier onlyOwner {
      require(msg.sender == owner,  "Only owner");
      _;
    }

    modifier onlyDAO {
      require(msg.sender == DAO, "Only DAO");
      _;
    }

    function setDescription (string memory _description) external onlyOwner {
        description = _description;
    }

    function setTags (string[] memory  _tags) external onlyOwner {
        tags = _tags;
    }

    function newOffer(DataTypes.Offer memory offer) external onlyDAO {
        console.log("newOffer: from", offer.offerMaker);
        
        Log.Offer(offer);
        insertOffer(offer);
        
        console.log("Trainer: DAO =", DAO, "Owner=", owner);
    }

    function newContract(JobContract job) external onlyDAO {
        console.log("newContract: ", owner);
        
        job.LogContract();
        insertContract(job);
    }

    function acceptOffer(uint256 offerID) external onlyDAO returns(DataTypes.Offer memory) {
        DataTypes.Offer memory offer;

        if(containsOffer(offerID)){
            offer = pendingOffers[offerID];
            deleteOffer(offerID);
        }

        return offer;
    }

    function getPendingOffers() external view onlyDAO returns(DataTypes.Offer [] memory) {

        DataTypes.Offer [] memory listPendingOffers = new DataTypes.Offer[](pendingOffersIDs.length);

        for (uint256 i = 0; i < pendingOffersIDs.length; i++) {
            DataTypes.Offer memory pendingOffer = pendingOffers[pendingOffersIDs[i]];

            listPendingOffers[i] = pendingOffer;            
        }

        return listPendingOffers;
    }

    function containsOffer(uint256 offerID) public view returns (bool){
        return (pendingOffers[offerID].trainer != address(0));
    }

    //FUNÇÕES AUXILIARES
    function insertOffer(DataTypes.Offer memory offer) internal {
        pendingOffers[offer.ID] = offer;
        pendingOffersIDs.push(offer.ID);

        console.log("insertOffer:" , offer.ID, " Count pending offers =", pendingOffersIDs.length);
    }

    function insertContract(JobContract job) internal {
        jobContracts[address(job)] = job;
        jobsAddress.push(address(job));

        console.log("insertContract:" ,address(job), " Count jobContracts =", jobsAddress.length);
    }

    function deleteOffer(uint256 offerID) internal {
        uint256 idxOffer = 0;
        bool    bFound   = false;
        //acha o index que a oferta está
        while ((idxOffer < pendingOffersIDs.length) && (!bFound)){
            if (pendingOffersIDs[idxOffer] == offerID) {
                bFound = true;
                break;
            }
            idxOffer++;
        }

        //Deleta
        if (bFound) {
            //Deleta a oferta da lista de IDs pendentes. Faz isso atribuindo no valor da ultima oferta no lugar da oferta a ser deletada, e então fazendo um pop do ultimo elemento.
            pendingOffersIDs[idxOffer] = pendingOffersIDs[pendingOffersIDs.length-1];
            pendingOffersIDs.pop();


            //Deleta a oferta do mapping
            delete pendingOffers[idxOffer];

            console.log("deleteOffer:" , offerID, idxOffer, pendingOffersIDs.length);
        }
        else {
            console.log("deleteOffer:" , offerID, "Not found");
        }
    }
}