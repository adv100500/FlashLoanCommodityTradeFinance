# Flash Loans in Commodity Trade Finance

Please see two examples below how **flash loans** could facilitate commodity trade finance transactions for commodity trading companies.

The proof of concept with the corresponding smart contracts is available as well as the testing script (please see "contracts" folder for smart contracts and "test" folder for testing script).

**Advantage of flash loans for commodity trading companies:**

As the whole transaction takes place in a few seconds, the advantage for the trading company is a much lower interest expense (**hundreds of thousands times**) compared to traditional borrowing. Basically, if we take an example of a transaction that lasts 30 days starting from payment to the supplier and until the payment of the final off-taker, this will require financing for 30 days usually collateralized by the goods (represented by the document of title, in the examples below by the bill of lading which will be sent to the financing bank in order for the bank to establish constructive possession over the goods). 
The same transaction performed on blockchain financed by a flash loan will take only a few seconds - therefore the interest rate will be charged only for a few seconds and no collateral is required. 


**Definitions**

**Flash loan:** flash loan is a type of loan that is only available during the duration of the transaction. The funds are borrowed at the beginning of the transaction and must be repaid at the end and **no collateral is required**. In case the funds are not repaid, the whole transaction is deemed null and void and reverted to its initial state and this is why there is no credit risk of the borrower involved. This is possible due to **atomicity** of blockchain transactions. 

**Atomicity:** an atomic transaction is an indivisible and irreducible series of database operations such that either all occurs, or nothing occurs. In this example several conditions are set in smart contracts for various checks, including but not limited to: checks if received funds correspond to the price of the goods, checks if tokenized goods were received, checks if sender is a smart contract, checks if borrower has enough funds to repay the flash loan plus interests. Should at least one of these conditions be in breach, the whole transaction is deemed null and void and reverted.

**Tokenized goods:** tokenized goods meaning tokenized document of title (ex. bill of lading), represented by an ERC20 token in this case.



![Untitled-2023-01-04-0945](https://user-images.githubusercontent.com/121932525/210520986-97da695a-9ac1-43fe-9e37-4e8cab31365d.png)

Here is the explanation of the scheme above:

1) Once the goods are loaded on a vessel, captain issues tokens for the amount of the goods (in this example - 100 tokens) and sends it to the supplier's contract.
2) Final off-taker checks the price of trader's contract and funds the contract accordingly (assuming 120 ether). The supplier's price for the goods is assumed 100 ethers, bank's interest rate is assumed 1 ether.
3) Starting from this point, everything happens in one single transaction, **meaning each following step is triggered automatically by the previous step**. First, trader takes a flash loan of 100 ether.
4) Upon reception of the flash loan, trader's contract automatically pays the supplier.
5) Supplier's contract automatically transfers the funds to the supplier's account upon reception of the payment from trader.
6) Supplier's contract transfers the tokens to trader's contract automatically upon reception of the payment from trader.
7) Once the tokens are received, it will trigger trader's contract to transfer the received tokens to the final off-taker's contract.
8) Final off-taker's contract automatically transfers the tokens to the final off-taker's account upon reception of the tokens.
9) Final off-taker's contract automatically transfers the funds to the trader's account (120 ether) upon reception of the tokens.
10) Once the funds are received, trader's contract will automatically repay the flash loan plus interest (101 ether).
11) Finally, trader's contract transfers profits to trader's account (19 ether).

![Screenshot 2023-01-04 201545](https://user-images.githubusercontent.com/121932525/210659447-ce457840-5cc9-413c-93bd-ad00a87262fc.png)


**Deferred payment:**

In this example above we have seen how flash loans could facilitate spot transaction, however could this be also applied to transactions with deferred payment? Please see below a possible solution:

![Untitled-2023-01-04-0945(1)](https://user-images.githubusercontent.com/121932525/210527951-8e5572fd-d573-4106-baac-02ef3df61080.png)

1) Once the goods are loaded on a vessel, captain issues tokens for the amount of the goods and sends it to the supplier's contract.
2) Starting from this point, everything happens in one single transaction, **meaning each following step is triggered automatically by the previous step**. First, trader takes a flash loan.
3) Trader pays the supplier.
4) Upon reception of the funds, supplier's contract will transfer the funds to the supplier's account.
5) Upon reception of the funds, supplier's contract transfers the tokens to trader's contract.
6) The reception of tokens by the trader's contract automatically triggers transfer of the received tokens to the final off-taker's contract.
7) Final off-taker's contract transfers the tokens to the final off-taker's account automatically upon reception of the tokens.
8) Final off-taker's contract transfers tokenized receivable to trader's contract automatically upon reception of the tokens.
9) Trader transfers tokenized receivable to the factoring provider automatically upon reception of the tokenized receivable.
10) Factoring provider automatically transfers the funds to trader's contract.
11) Reception of the funds by the trader's contract will automatically trigger repayment of the flash loan plus interest.
12) Finally, trader's contract transfers profits to trader's account.
