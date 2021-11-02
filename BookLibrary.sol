// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./Ownable.sol";

contract BookLibrary is Ownable {
    struct Book {
        string name;
        string author;
        string isbn;
        uint copies;
    }
    
    struct BorrowedBook {
        bool borrowed;
        bool previouslyBorrowed;
    }
    
    // books and number of copies available
    mapping (uint => Book)  public books;
    // keep list to iterate over
    string[] isbns;
    // availability of books by id
    mapping (uint => uint) public availability;
    
    event NewBook(uint bookId, string name, string author);
    
    function addBook(string memory _name, string memory _author, string memory _isbn, uint _copies) public onlyOwner {
        // cannot have zero or negative amount of copies
        require(_copies > 0, "Copies must be positive number");
        require(bytes(_name).length > 0 && bytes(_author).length > 0 && bytes(_isbn).length > 0, "Title, author and ISBN should be nonempty.");
        
        // store book in mapping
        uint bookId = uint(keccak256(abi.encodePacked(_isbn)));
        require(books[bookId].copies == 0, "Book with this ISBN exists.");
        books[bookId] = Book(_name, _author, _isbn, _copies);
        // and available isbns
        isbns.push(_isbn);
        
        availability[bookId] = _copies;
        emit NewBook(bookId, _name, _author);
    }
    
    function addCopies(uint _bookId, uint _newCopiesAmount) public onlyOwner {
        books[_bookId].copies += _newCopiesAmount;
        availability[_bookId] += _newCopiesAmount;
    }
    
    
}