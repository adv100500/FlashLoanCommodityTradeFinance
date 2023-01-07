const { ethers } = require('hardhat');
const { expect } = require('chai');

describe('[Trade Finance Flash loan]', function () {
    let buyer, bank, captain, borrower, offtaker,traderInitialBalance,supplierInitialBalance,offtakerInitialBalance;

    // Bank has 1K * 10**18 tokens
    const MONEY_IN_POOL = ethers.utils.parseEther('1000');
    const FLASHLOAN= ethers.utils.parseEther('100');
    const SalePrice= ethers.utils.parseEther('120');
    const INITIAL_GOODS_TOKEN_BALANCE = ethers.utils.parseEther('100');
    const FEE=ethers.utils.parseEther('1');

    before(async function () {
        /** SETUP SCENARIO */

        [buyer, bank, captain, borrower, offtaker] = await ethers.getSigners();

        // Initialize contract factories
        const GoodsTokenFactory = await ethers.getContractFactory('SomeGoodsToken', captain);
        const FlashBankFactory = await ethers.getContractFactory('FlashLoanBank', bank);
        const PurchaseFactory = await ethers.getContractFactory('PurchaseContract', buyer);
        const SellerFactory = await ethers.getContractFactory('SalesContract', offtaker);
        const FlashLoanBorrowerFactory = await ethers.getContractFactory('FlashLoanBorrowerTrader', borrower);
        
        // Deploy contracts
        this.token = await GoodsTokenFactory.deploy();
        this.bank = await FlashBankFactory.deploy();
        this.supplier = await PurchaseFactory.deploy(buyer.address, this.token.address);
        this.endBuyer = await SellerFactory.deploy(offtaker.address, this.token.address);
        this.trader = await FlashLoanBorrowerFactory.deploy(this.bank.address, this.token.address, this.endBuyer.address, this.supplier.address, borrower.address);

        // Initial balance of the trader supplier and off-taker
        traderInitialBalance=await ethers.provider.getBalance(borrower.address);
        supplierInitialBalance=await ethers.provider.getBalance(buyer.address);
        offtakerInitialBalance=await ethers.provider.getBalance(offtaker.address);
        
        // Transfer funds to bank's contract         
        await bank.sendTransaction({ to: this.bank.address, value: MONEY_IN_POOL });

        // Check money in bank's contract pool
        expect(await ethers.provider.getBalance(this.bank.address)).to.be.equal(MONEY_IN_POOL);

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

        // Final off-taker sends purchase price to its contract to be able to trade
        await offtaker.sendTransaction({ to: this.endBuyer.address, value: SalePrice });      

        // Check if seller's contract is funded correctly
        expect(await ethers.provider.getBalance(this.endBuyer.address)).to.be.equal(SalePrice); 

        // Initiate Flash loan
        await this.bank.connect(borrower).flashLoan(this.trader.address, FLASHLOAN);
        
    });

    after(async function () {
        /** SUCCESS CONDITIONS */

        // The balance of final off-taker has Goods tokens:
        expect(
            await this.token.balanceOf(offtaker.address)
        ).to.equal(INITIAL_GOODS_TOKEN_BALANCE);

        // Trader's margin    
        console.log("Trader's margin: ",Math.round(ethers.utils.formatEther(await ethers.provider.getBalance(borrower.address))
        -ethers.utils.formatEther(traderInitialBalance)));

        // Supplier's income    
        console.log("Supplier's income: ",Math.round(ethers.utils.formatEther(await ethers.provider.getBalance(buyer.address))
        -ethers.utils.formatEther(supplierInitialBalance)));

        // Seller's payment    
        console.log("Seller's payment: ", Math.round(ethers.utils.formatEther(await ethers.provider.getBalance(offtaker.address))
        -ethers.utils.formatEther(offtakerInitialBalance)));

        // Trader made some margin:       
        expect(await ethers.provider.getBalance(borrower.address)).to.be.gt(traderInitialBalance); 

        // Supplier received funds:
        expect(await ethers.provider.getBalance(buyer.address)).to.be.gt(supplierInitialBalance); 
            
        // Off-taker paid the price:
        expect(await ethers.provider.getBalance(offtaker.address)).to.be.lt(offtakerInitialBalance);
    });

    
});
