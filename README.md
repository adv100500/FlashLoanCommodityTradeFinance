# FlashLoan Commodity Trade Finance

Here is an example of how flash loans can facilitate commodity trade finance transactions (in the below example a spot transaction assumed with no deferred payment):

![Untitled-2023-01-04-0945](https://user-images.githubusercontent.com/121932525/210520986-97da695a-9ac1-43fe-9e37-4e8cab31365d.png)

The proof of concept with the corresponding smart contracts is available as well as the testing script (please see "contracts" folder for smart contracts and "test" folder for testing script).

Here is the explanation of the scheme above:

1) Once the goods are loaded on a vessel, captain issues tokens for the amount of the goods (in this example - 100 tokens) and sends it to the supplier's contract.
2) Final off-taker checks the price of trader's contract and funds the contract accordingly (assuming 120 ether). The supplier's price for the goods is assumed 100 ethers, bank's interest rate is assumed 1 ether.
3) Starting from this point, everything happens in one single transaction. First, trader takes a flash loan of 100 ether.
4) Trader pays the supplier.
5) Supplier's contract transer the funds to the supplier's account.
6) Supplier's contract transfer the tokens to trader's contract.
7) Trader's contract transfer the received tokens to the final off-taker's contract.
8) Final off-taker's contract transfer the tokens to the final off-taker's account.
9) Final off-taker's contract transfer the funds to the trader's account (120 ether).
10) Trader's contract repays the flash loan plus interest (101 ether).
11) Trader's contract transfers the profit to the trader's account (19 ether).

**Final Thoughts:**

In this example we have analyzed spot transaction, however could this be applied also to transactions with deferred payment? Please see another scheme below:
