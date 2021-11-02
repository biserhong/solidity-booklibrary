// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./BookLibrary.sol";


contract BookBorrowing is BookLibrary {
    // borrowed books by address
    mapping (address => mapping (uint => BorrowedBook)) public borrowings;
    mapping (uint => address[]) borrowersByBook;
    
    function listAvailableBooks() external view returns (Book[] memory) {
        uint counter = 0;
        for (uint i = 0; i < isbns.length; i++) {
            uint bookId = uint(keccak256(abi.encodePacked(isbns[i])));
            if (availability[bookId] > 0) {
                counter++;
            }
        }
        
        Book[] memory availableBooks = new Book[](counter);
        counter = 0;
        for (uint i = 0; i < isbns.length; i++) {
            uint bookId = uint(keccak256(abi.encodePacked(isbns[i])));
            if (availability[bookId] > 0) {
                availableBooks[counter] = Book(books[bookId].name, books[bookId].author, books[bookId].isbn, availability[bookId]);
                counter++;
            }
        }
        
        return availableBooks;
    }
    
    function listBorrowersByBook(string memory _isbn) external view returns (address[] memory) {
        uint bookId = uint(keccak256(abi.encodePacked(_isbn)));
        return borrowersByBook[bookId];
    }
    
    function borrowBook(string memory _isbn) external {
        uint bookId = uint(keccak256(abi.encodePacked(_isbn)));
        require(!borrowings[msg.sender][bookId].borrowed, "Book already borrowed");
        require(availability[bookId] > 0, "No copies available");
        
        borrowings[msg.sender][bookId].borrowed = true;
        // insert borrower only first time they borrow a book
        if (!borrowings[msg.sender][bookId].previouslyBorrowed) {
            borrowings[msg.sender][bookId].previouslyBorrowed = true;
            borrowersByBook[bookId].push(msg.sender);
        }
        availability[bookId] -= 1;
    }
    
    function returnBook(string memory _isbn) external {
        uint bookId = uint(keccak256(abi.encodePacked(_isbn)));
        require(borrowings[msg.sender][bookId].borrowed, "Book was not previously borrowed");
        
        borrowings[msg.sender][bookId].borrowed = false;
        availability[bookId] += 1;
    }
}