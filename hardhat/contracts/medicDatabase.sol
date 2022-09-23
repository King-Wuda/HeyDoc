// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

error NotListed();
error AlreadyListed();
error NotOwner();
error NotApprovedForMarketplace();
error NoProceeds();

contract MedicDatabase {
    struct Doctor {
        address doctor;
        string name;
        string specialty;
        string degree;
        string university;
        uint256 experience;
        uint256 surgeries;
        bool active;
        bool verified;
        uint256 price;
    }

    event DoctorListed(
        address doctor,
        string name,
        string degree,
        string university,
        string specialty,
        uint256 experience,
        uint256 surgeries,
        bool active,
        bool verfied,
        uint256 price
    );

    event DoctorCanceled(address doctor);

    event DoctorChanged(
        address doctor,
        string name,
        string specialty,
        string degree,
        string university,
        uint256 experience,
        uint256 surgeries,
        bool active,
        bool verified,
        uint256 price
    );

    mapping(address => uint256) private s_proceeds;
    mapping(address => Doctor) private s_listings;

    address[] public addys;

    modifier notListed(address doctor) {
        Doctor memory listing;
        if (listing.verified) {
            revert AlreadyListed();
        }
        _;
    }

    modifier isListed(address doctor) {
        Doctor memory listing;
        if (listing.experience == 0) {
            revert NotListed();
        }
        _;
    }

    modifier isOwner(address doctor) {
        if (msg.sender != doctor) {
            revert NotOwner();
        }
        _;
    }

    function listDoctor(
        address doctor,
        string memory name,
        string memory specialty,
        string memory degree,
        string memory university,
        uint256 experience,
        uint256 surgeries,
        bool active,
        bool verified,
        uint256 price
    ) external notListed(doctor) {
        s_listings[msg.sender] = Doctor(
            msg.sender,
            name,
            specialty,
            degree,
            university,
            experience,
            surgeries,
            active,
            verified,
            price
        );
        addys.push(doctor);
        // add address to array
        emit DoctorListed(
            msg.sender,
            name,
            specialty,
            degree,
            university,
            experience,
            surgeries,
            active,
            verified,
            price
        );
    }

    function verifyDoctor(address doctor)
        external
        view
        isListed(doctor)
        isOwner(doctor)
    {
        Doctor memory listing = s_listings[doctor];
        listing.verified = true;
    }

    function buyConsultation(address doctor)
        public
        payable
        isListed(doctor)
        isOwner(doctor)
    {
        Doctor memory listing = s_listings[doctor];
        require(msg.value >= listing.price, "Matic sent is not correct");
        // put one time link notification to receive details of meeting
        s_proceeds[doctor] += msg.value;
    }

    function changeDoctor(
        address doctor,
        string memory name,
        string memory specialty,
        string memory degree,
        string memory university,
        uint256 experience,
        uint256 surgeries,
        bool active,
        bool verified,
        uint256 price
    ) external isListed(doctor) isOwner(doctor) {
        // change doctor listing and restore data from Ipfs
        Doctor memory listing = s_listings[doctor];
        listing.doctor = doctor;
        listing.name = name;
        listing.specialty = specialty;
        listing.degree = degree;
        listing.university = university;
        listing.experience = experience;
        listing.surgeries = surgeries;
        listing.active = active;
        listing.verified = verified;
        listing.price = price;
        emit DoctorChanged(
            msg.sender,
            name,
            specialty,
            degree,
            university,
            experience,
            surgeries,
            active,
            verified,
            price
        );
    }

    function cancelListing(address doctor)
        public
        isListed(doctor)
        isOwner(doctor)
    {
        delete (s_listings[doctor]);
        // pop item from array
        for (uint i = 0; i < addys.length; i++) {
            if (addys[i] == doctor) {
                addys[i] = addys[addys.length - 1];
                addys.pop();
            }
        }
        emit DoctorCanceled(msg.sender);
    }

    function getListing(address doctor) external view returns (Doctor memory) {
        Doctor memory listing = s_listings[doctor];
        return listing;
    }

    function getArray() public view returns (address[] memory) {
        return addys;
    }

    function withdrawProceeds()
        external
        isOwner(msg.sender)
        isListed(msg.sender)
    {
        Doctor memory listing = s_listings[msg.sender];
        require(listing.verified = true, "Not verified - cannot withdraw");
        uint256 proceeds = s_proceeds[msg.sender];
        if (proceeds <= 0) {
            revert NoProceeds();
        }
        s_proceeds[msg.sender] = 0;
        (bool success, ) = payable(msg.sender).call{value: proceeds}("");
        require(success, "Transfer failed");
    }

    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}
}
