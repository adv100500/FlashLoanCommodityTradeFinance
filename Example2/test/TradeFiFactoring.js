const { ethers } = require('hardhat');
const { expect } = require('chai');

describe('[Trade Finance Flash loan]', function () {
    let buyer, bank, captain, borrower, offtaker,traderInitialBalance,supplierInitialBalance,offtakerInitialBalance, factoringInitialBalance;

    // Bank has 1K * 10**18 tokens
    const MONEY_IN_POOL = ethers.utils.parseEther('1000');
    const FLASHLOAN= ethers.utils.parseEther('100');
    const SalePrice= ethers.utils.parseEther('120');
    const INITIAL_GOODS_TOKEN_BALANCE = ethers.utils.parseEther('100');
    const FEE=ethers.utils.parseEther('1');

    before(async function () {
        /** SETUP SCENARIO */

        [buyer, bank, captain, borrower, offtaker, factoring] = await ethers.getSigners();

        // Initialize contract factories
        const GoodsTokenFactory = await ethers.getContractFactory('SomeGoodsToken', captain);
        const FlashBankFactory = await ethers.getContractFactory('FlashLoanBank', bank);
        const PurchaseFactory = await ethers.getContractFactory('PurchaseContract', buyer);
        const SellerFactory = await ethers.getContractFactory('SalesContractReceivable', offtaker);
        const FlashLoanBorrowerFactory = await ethers.getContractFactory('FlashLoanBorrowerTraderReceivables', borrower);
        const factoringFactory = await ethers.getContractFactory('Factoring', factoring);
        const ReceivableTokenFactory = await ethers.getContractFactory('ReceivableToken', offtaker);
        
        // Deploy contracts
        this.token = await GoodsTokenFactory.deploy();
        this.bank = await FlashBankFactory.deploy();
        this.supplier = await PurchaseFactory.deploy(buyer.address, this.token.address);
        this.endBuyer = await SellerFactory.deploy(offtaker.address, this.token.address);
        this.factoring = await factoringFactory.deploy();
        this.trader = await FlashLoanBorrowerFactory.deploy(this.bank.address, this.token.address, this.endBuyer.address, this.supplier.address, borrower.address, this.factoring.address);
        this.receivableToken = await ReceivableTokenFactory.attach(await this.endBuyer.receivableToken());       
                
        // Transfer funds to bank's contract         
        await bank.sendTransaction({ to: this.bank.address, value: MONEY_IN_POOL });

        // Transfer funds to factoring contract         
        await factoring.sendTransaction({ to: this.factoring.address, value: MONEY_IN_POOL });     
        
        // Initial balance of the trader supplier and off-taker
        traderInitialBalance=await ethers.provider.getBalance(borrower.address);
        supplierInitialBalance=await ethers.provider.getBalance(buyer.address);
        offtakerInitialBalance=await ethers.provider.getBalance(offtaker.address);        
        factoringInitialBalance=await ethers.provider.getBalance(this.factoring.address);  

        // Check money in bank's contract pool
        expect(await ethers.provider.getBalance(this.bank.address)).to.be.equal(MONEY_IN_POOL);

        // Check money in factoring contract pool
        expect(await ethers.provider.getBalance(this.factoring.address)).to.be.equal(MONEY_IN_POOL);        

        // Check bank's fee
        expect(await this.bank.fixedFee()).to.be.equal(ethers.utils.parseEther('1'));

        // Check captain's balance
        expect(
            await this.token.balanceOf(captain.address)
        ).to.equal(INITIAL_GOODS_TOKEN_BALANCE);        
           
        // Captain transfers goods token to supplier's contract 
        await this.token.transfer(this.supplier.address, INITIAL_GOODS_TOKEN_BALANCE);
           
        // Check goods token in supplier's contract
        expect(
            await this.token.balanceOf(this.supplier.address)
        ).to.equal(INITIAL_GOODS_TOKEN_BALANCE);



    });

    it('Flash loan transaction', async function () {
        
        ///Final off-taker sets Borrower as supplier
        await this.endBuyer.connect(offtaker).setSupplier(this.trader.address);

        // Initiate Flash loan
        await this.bank.connect(borrower).flashLoan(this.trader.address, FLASHLOAN);
        
    });

    after(async function () {
        /** SUCCESS CONDITIONS */
        expect(await this.receivableToken.totalSupply()).to.be.eq(ethers.utils.parseEther('120'));
        // The balance of final off-taker has Goods tokens:
        expect(
            await this.token.balanceOf(offtaker.address)
        ).to.equal(INITIAL_GOODS_TOKEN_BALANCE);

        // Trader made some margin:       
        expect(await ethers.provider.getBalance(borrower.address)).to.be.gt(traderInitialBalance); 

        // Supplier received funds:
        expect(await ethers.provider.getBalance(buyer.address)).to.be.gt(supplierInitialBalance); 

        // Factoring received receivables tokens
        
        expect(await this.receivableToken.balanceOf(this.factoring.address)).to.be.gt(0);

        // Trader's margin    
        console.log("Trader's margin: ",Math.round(ethers.utils.formatEther(await ethers.provider.getBalance(borrower.address))
        -ethers.utils.formatEther(traderInitialBalance)));

        // Supplier's income    
        console.log("Supplier's income: ",Math.round(ethers.utils.formatEther(await ethers.provider.getBalance(buyer.address))
        -ethers.utils.formatEther(supplierInitialBalance)));

        // Seller's payment    
        console.log("Seller's payment: ", Math.round(ethers.utils.formatEther(offtakerInitialBalance)-ethers.utils.formatEther(await ethers.provider.getBalance(offtaker.address))
        ));

        // Factoring receivable token balance:
        console.log("Factoring receivable token balance: ", Math.round(ethers.utils.formatEther(await this.receivableToken.balanceOf(this.factoring.address))-ethers.utils.formatEther(0)));

        // Factoring funds payment:
        console.log("Factoring funds balance: ", Math.round(ethers.utils.formatEther(await ethers.provider.getBalance(this.factoring.address))-ethers.utils.formatEther(factoringInitialBalance)));        

    });
 
});
