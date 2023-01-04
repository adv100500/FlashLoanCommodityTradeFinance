# FlashLoan Commodity Trade Finance

Here is an example of how flash loans could facilitate commodity trade finance transactions (in the below example a spot transaction assumed with no deferred payment):

The proof of concept with the corresponding smart contracts is available as well as the testing script (please see "contracts" folder for smart contracts and "test" folder for testing script).

![Untitled-2023-01-04-0945](https://user-images.githubusercontent.com/121932525/210520986-97da695a-9ac1-43fe-9e37-4e8cab31365d.png)

Here is the explanation of the scheme above:

1) Once the goods are loaded on a vessel, captain issues tokens for the amount of the goods (in this example - 100 tokens) and sends it to the supplier's contract.
2) Final off-taker checks the price of trader's contract and funds the contract accordingly (assuming 120 ether). The supplier's price for the goods is assumed 100 ethers, bank's interest rate is assumed 1 ether.
3) Starting from this point, everything happens in one single transaction. First, trader takes a flash loan of 100 ether.
4) Trader pays the supplier.
5) Supplier's contract transfers the funds to the supplier's account.
6) Supplier's contract transfers the tokens to trader's contract.
7) Trader's contract transfers the received tokens to the final off-taker's contract.
8) Final off-taker's contract transfers the tokens to the final off-taker's account.
9) Final off-taker's contract transfers the funds to the trader's account (120 ether).
10) Trader's contract repays the flash loan plus interest (101 ether).
11) Trader's contract transfers profits to trader's account (19 ether).

![Screenshot 2023-01-04 201545](https://user-images.githubusercontent.com/121932525/210659447-ce457840-5cc9-413c-93bd-ad00a87262fc.png)


**Deferred payment:**

In this example above we have seen how flash loans could facilitate spot transaction, however could this be also applied to transactions with deferred payment? Please see below a possible solution:

![Untitled-2023-01-04-0945(1)](https://user-images.githubusercontent.com/121932525/210527951-8e5572fd-d573-4106-baac-02ef3df61080.png)

1) Once the goods are loaded on a vessel, captain issues tokens for the amount of the goods and sends it to the supplier's contract.
2) Starting from this point, everything happens in one single transaction. First, trader takes a flash loan.
3) Trader pays the supplier.
4) Supplier's contract transfers the funds to the supplier's account.
5) Supplier's contract transfers the tokens to trader's contract.
6) Trader's contract transfer the received tokens to the final off-taker's contract.
7) Final off-taker's contract transfers the tokens to the final off-taker's account.
8) Final off-taker's contract transfers tokenized receivable to trader's contract.
9) Trader transfers tokenized receivable to the factoring provider.
10) Factoring provider transfers the funds to trader's contract.
11) Trader's contract repays the flash loan plus interest.
12) Trader's contract transfers profits to trader's account.

**Advantage of flash loans for the flash loan bank:**

Due to atomicity (https://en.wikipedia.org/wiki/Atomicity_(database_systems)) of blockchain transaction, flash loan bank is able to provide a completely uncollateralized flash loan and is not exposed to borrower's credit risk. In other words, should something go wrong during the transaction (supplier does not send the tokenized goods, off-taker does not send the required funds, etc...), the transaction will be reverted to its initial state.

**Advantage of flash loans for the trader:**

As the whole transaction takes place in seconds, the advantage for the trader is a much lower interest expenses compared to traditional borrowing.

