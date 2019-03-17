pragma solidity >=0.4.0 <0.6.0;

contract Owned {
  // State variables
  address payable owner;

  //modifiers
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  // constructor
  constructor () public {
    owner = msg.sender;
  }
}

contract LandContract is Owned {

          // Custom types
          struct Land {
                uint id;
                address payable seller;
                address payable buyer;
                string name;
                string description;
                uint256 price;
            
          }
          
          //structure for seller identites
          struct Seller {
                uint id;
                address payable sellerAddress;
                uint review;
          }
          
          //structure for buyer identites
          struct Buyer {
                uint id;
                address payable buyerAddress;
                uint review;
          }
          
          //mapping land for selling and buying
          //set variables for seller count and buyer
          mapping(uint => Seller) public seller;
          uint sellerCount = 0;
          mapping(uint => Buyer) public buyer;
          uint buyerCount = 0 ;
          
          
          
          //mapping land for selling and buying
          mapping(uint => Land) public lands;
          uint landCounter;
          
          
          //set a static ether value in indian rupees
          uint ethCounter=9183;
          
          /*//mapping to check whether to show land
          mapping(uint =>bool) public isAllowToDisplay;
          
          
          //funtion to allow display
          function allowToDisplay(uint _id) public
          {
              isAllowToDisplay[_id]=true;
          }
          
          
          //funtion to disallow display
          function disallowToDisplay(uint _id) public
          {
              isAllowToDisplay[_id]=false;
          }
          
          */
          
          //feedback check
          
          
          
          //check the value of owner 
          function displayOwner() public view returns (address)
          {
              return owner;
          }
          
          
          //events
          event sellLandEvent(
            uint indexed _id,
            address indexed _seller,
            string _name,
            uint256 _price);
        
          event buyLandEvent(
            uint indexed _id,
            address indexed _seller,
            address indexed _buyer,
            string _name,
            uint256 _price);
        
          event returnLandEvent(
            uint indexed _id,
            address indexed _seller,
            address indexed _buyer,
            string _name,
            uint256 _price);
          
          
          //selling land ,giving details of land
          function sellLand(string memory _name, string memory _description, uint256 _price) public {
                    // a new land
                    landCounter++;
                    _price=_price/ethCounter;
                
                    //store this land
                    lands[landCounter] = Land(
                        landCounter,
                        msg.sender,
                        address(0),
                        _name,
                        _description,
                        _price
                      );
                    
                    uint count=0;
                    for (uint i = 1; i <= sellerCount; i++) 
                     {
                        if (seller[i].sellerAddress == msg.sender) {
                        count ++;
                       }
                     }
                     if (count ==0) {
                        sellerCount++;
                        seller[sellerCount]=Seller(sellerCount,msg.sender,0);
                     }
                    
                    emit sellLandEvent(landCounter, msg.sender, _name, _price);
          }
        
        
          //function for getting number of lands in total
          function getNumberOfLands() public view returns (uint) {
                 return landCounter;
          }
        
          
          //function for getting lands available for sale
          function getLandsForSale() public view returns (uint[] memory) {
                    if(landCounter == 0) {
                      return new uint[](0);
                    }
                
                    uint[] memory landIds = new uint[](landCounter);
                
                    uint numberOfLandsForSale = 0;
                    for (uint i = 1; i <= landCounter; i++) {
                      if (lands[i].buyer == address(0)) {
                        landIds[numberOfLandsForSale] = lands[i].id;
                        numberOfLandsForSale++;
                      }
                    }
                
                    uint[] memory forSale = new uint[](numberOfLandsForSale);
                    for (uint j = 0; j < numberOfLandsForSale; j++) {
                      forSale[j] = landIds[j];
                    }
                    return (forSale);
          }
          
          //function for getting  Lands sold
          function getLandsSold() public view returns (uint[] memory) {
                    if(landCounter == 0) {
                            return new uint[](0);
                    }
                
                    uint[] memory landSoldIds = new uint[](landCounter);
                
                    uint numberOfLandsSold = 0;
                    for (uint i = 1; i <= landCounter; i++) {
                      if (lands[i].buyer != address(0)) {
                        landSoldIds[numberOfLandsSold] = lands[i].id;
                        numberOfLandsSold++;
                      }
                    }
                
                    uint[] memory forReturn = new uint[](numberOfLandsSold);
                    for (uint j = 0; j < numberOfLandsSold; j++) {
                      forReturn[j] = landSoldIds[j];
                    }
                    return (forReturn);
          }
          
          
          //function for buying Lands 
          function buyLand(uint _id) payable public {
                    // we check whether there is at least one land
                    require(landCounter > 0);
                
                    // we check whether the land exists
                    require(_id > 0 && _id <= landCounter);
                
                    // we retrieve the land
                    Land storage land = lands[_id];
                
                    // we check whether the land has not already been sold
                    require(land.buyer == address(0));
                
                    // we don't allow the seller to buy his/her own land
                    require(land.seller != msg.sender);
                
                    // we check whether the value sent corresponds to the land price
                    //require(land.price == msg.value);
                
                    // keep buyer's information
                    land.buyer = msg.sender;
                
                    // the buyer can buy the land
                    land.seller.transfer(msg.value);
                    
                    uint count=0;
                    for (uint i = 1; i <= buyerCount; i++) 
                     {
                        if (buyer[i].buyerAddress == msg.sender) {
                        count ++;
                       }
                     }
                     if (count ==0) {
                        buyerCount++;
                        buyer[buyerCount]=Buyer(buyerCount,msg.sender,0);
                     }
                   
                    emit buyLandEvent(_id, land.seller, land.buyer, land.name, land.price);
            }
            
            
            //funtion to return the land
            function returnLand(uint _id) public {
                    // we check whether there is at least one land
                    require(landCounter > 0);
                
                    // we check whether the land exists
                    require(_id > 0 && _id <= landCounter);
                
                    // we retrieve the land
                    Land storage land = lands[_id];
                
                    // we check whether the land has  already been sold the same person
                    require(land.buyer == msg.sender);
                
                    // we don't allow the seller to buy his/her own land
                    //require(land.seller != msg.sender);
                
                    // we check whether the value sent corresponds to the land price
                    //require(land.price == msg.value);
                    
                    // keep buyer's information
                    land.buyer = address(0);
                
                    emit returnLandEvent(_id, land.seller, land.buyer, land.name, land.price);
            } 
            
            
            
            //review a seller
            function review(uint _landId) public {
                    
                    uint count=0;
                    //check in lands whether he brought a land
                    for (uint i = 1; i <= landCounter; i++) {
                          if (lands[i].buyer == msg.sender) {
                              
                              //check the seller address math with the land seller address and seller id with given id
                              for (uint j = 1; j <= sellerCount; j++){
                                if ((lands[i].seller == seller[j].sellerAddress)&&(seller[j].id==_landId)){
                                    
                                        seller[j].review++;
                                        count++;
                                        break;
                                    }
                                } 
                           }
                           if(count!=0){
                               break;
                           }
                    }
            }
        
            //function to change price of a lands
            function increasePrice(uint _landId,uint landPrice) public  {
                for (uint i = 1; i <= landCounter; i++) {
                    if ((lands[i].id == _landId)&&(lands[i].seller ==msg.sender))
                    {
                       landPrice=landPrice/ethCounter;
                        lands[i].price = landPrice;
                    }
                }    
            }
            
            
            //kill the smart contract
            function kill() public onlyOwner {
                     selfdestruct(owner);
          }
}
