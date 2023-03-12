// SPDX-License-Identifier: MIT
pragma solidity =0.8.13;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

/**
* @title BUK Protocol Supplier Utility Contract
* @author BUK Technology Inc
* @dev Contract for managing Proof-of-Stay utility NFT ERC1155 token
*/
contract SupplierUtilityContract is AccessControl, ERC1155 {

    /**
    * @dev name of the supplier contract
    */
    string public name;
    /**
    * @dev address of the utility contract
    */
    address public supplierContract;
    /**
    * @dev Contract URI string
    */
    string private contractUri;

    /**
    * @dev Struct for supplier data
    * @var id Supplier ID
    * @var name Supplier name
    */
    struct SupplierData {
        uint256 id;
        bytes32 name;
    }

    /**
    * @dev Supplier data instance
    */
    SupplierData public details;

    /**
    * @dev Mapping for token URI's for booked tickets
    */
    mapping(uint256 => string) public bookingTickets; //tokenID -> uri

    /**
    * @dev Constant for the role of the supplier contract
    */
    bytes32 public constant SUPPLIER_CONTRACT_ROLE = keccak256("SUPPLIER_CONTRACT");
    /**
    * @dev Constant for the role of the factory contract
    */
    bytes32 public constant FACTORY_CONTRACT_ROLE = keccak256("FACTORY_CONTRACT");

    /**
    * @dev Event to set the contract URI
    */
    event SetContractURI(string indexed contractUri);
    /**
    * @dev Event to grant supplier contract role
    */
    event GrantSupplierRole(address indexed supplier);
    /**
    * @dev Event to safe transfer NFT
    */
    event GrantFactoryRole(address indexed oldFactory, address indexed newFactory);
    /**
    * @dev Event to update the supplier details
    */
    event UpdateSupplierdetails(string indexed name);
    /**
    * @dev Event to set token URI
    */
    event SetURI(uint indexed id, string indexed uri);
    /**
    * @dev Custom error in the function to transfer NFTs.
    */
    error NonTransferable(string message);

    /**
    * @dev Constructor to initialize the contract
    * @param _contractName Contract Name
    * @param _id Supplier ID
    * @param _name Supplier name
    * @param _factoryContract Address of the factory contract
    * @param _contractUri Contract URI string
    */
    constructor(string memory _contractName, uint256 _id, bytes32 _name, address _factoryContract, string memory _contractUri) ERC1155("") {
        details.id = _id;
        details.name = _name;
        name = _contractName;
        contractUri = _contractUri;
        _setRoleAdmin(FACTORY_CONTRACT_ROLE, SUPPLIER_CONTRACT_ROLE);
        _grantRole(FACTORY_CONTRACT_ROLE, _factoryContract);
    }

    /**
    * @dev Function to grant the supplier role to a given contract
    * @param _supplierContract address: The address of the supplier contract
    * @notice This function can only be called by a contract with `FACTORY_CONTRACT_ROLE`
    */
    function grantSupplierRole(address _supplierContract) external onlyRole(FACTORY_CONTRACT_ROLE)  {
        _grantRole(SUPPLIER_CONTRACT_ROLE, _supplierContract);
        supplierContract = _supplierContract;
        emit GrantSupplierRole(_supplierContract);
    }

    /**
    * @dev To set the factory role.
    * @param _factoryContract - Address of factory contract
    */
    function grantFactoryRole(address _factoryContract) external onlyRole(SUPPLIER_CONTRACT_ROLE) {
        _grantRole(FACTORY_CONTRACT_ROLE, _factoryContract);
        revokeRole(FACTORY_CONTRACT_ROLE, _msgSender());
        emit GrantFactoryRole(_msgSender(), _factoryContract);
    }

    /**
    * @dev Function to set the URI for a given ID
    * @param _id uint256: The ID of the token
    * @param _newuri string: The new URI of the token
    * @notice This function can only be called by a contract with `FACTORY_CONTRACT_ROLE`
    */
    function setURI(uint256 _id, string memory _newuri) external onlyRole(SUPPLIER_CONTRACT_ROLE) {
        _setURI(_id,_newuri);
        emit SetURI(_id,_newuri);
    }

    /**
    * @dev Function to set the contract URI
    * @param _contractUri string: The new URI of the contract
    * @notice This function can only be called by a contract with `SUPPLIER_CONTRACT_ROLE`
    */
    function setContractURI(string memory _contractUri) external onlyRole(SUPPLIER_CONTRACT_ROLE) {
        contractUri = _contractUri;
        emit SetContractURI(contractUri);
    }
    
    /**
    * @dev Function to update the supplier details
    * @param _name string: The new name of the supplier
    * @notice This function can only be called by a contract with `SUPPLIER_CONTRACT_ROLE`
    */
    function updateSupplierDetails(bytes32 _name, string memory _contractName) external onlyRole(SUPPLIER_CONTRACT_ROLE) {
        details.name = _name;
        name = _contractName;
        emit UpdateSupplierdetails(name);
    }

    /**
    * @dev Function to mint tokens
    * @param account address: The address to which the tokens will be minted
    * @param _id uint256: The ID of the token
    * @param amount uint256: The amount of tokens to be minted
    * @param _newuri string: The URI of the token
    * @param data bytes: Additional data associated with the token
    * @notice This function can only be called by a contract with `SUPPLIER_CONTRACT_ROLE`
    */
    function mint(address account, uint256 _id, uint256 amount, string calldata _newuri, bytes calldata data) external onlyRole(SUPPLIER_CONTRACT_ROLE) {
        _mint(account, _id, amount, data);
        _setURI(_id,_newuri);
    }
   
    /**
    * @dev Function to get the contract URI
    * @return uri - The URI of the contract
    */
    function contractURI() public view returns (string memory) {
        return contractUri;
    }

    /**
    * @dev Function to get the URI for a given ID
    * @param id uint256: The ID of the token
    * @return id - The URI of the token
    */
    function uri(uint256 id) public view virtual override returns (string memory) {
        return bookingTickets[id];
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view override(AccessControl, ERC1155) returns (bool) {
        return super.supportsInterface(interfaceId);
    } 

    /**
    * @dev Transfers ownership of an NFT token from one address to another.
    * @param from - The current owner of the NFT.
    * @param to - The address to transfer the ownership to.
    * @param id - The ID of the NFT token.
    * @param data - Additional data to include in the transfer.
    * @notice This function is to disable the transfer functionality of the utility tokens
    */
    function _safeTransferFrom( address from, address to, uint256 id, uint256 amount, bytes memory data ) internal virtual override {
        revert NonTransferable("Token transfer not allowed.");
    }    

    /**
    * @dev Transfers ownership of multiple NFT tokens from one address to another.
    * @param from - The current owner of the NFTs.
    * @param to - The address to transfer the ownership to.
    * @param ids - The IDs of the NFT tokens.
    * @param data - Additional data to include in the transfer.
    * @notice This function is to disable the batch transfer functionality of the utility tokens
    */
    function _safeBatchTransferFrom( address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data ) internal virtual override {
        revert NonTransferable("Token transfer not allowed.");
    }

    function _setURI(uint256 id, string memory newuri) internal {
        bookingTickets[id] = newuri;
    }
}
