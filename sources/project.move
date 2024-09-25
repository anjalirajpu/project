module MyModule::RentalAgreement {

    use aptos_framework::coin;
    use aptos_framework::signer;
    use aptos_framework::aptos_coin::{AptosCoin};

    struct RentalDeposit has store, key {
        tenant: address,
        deposit_amount: u64,
    }

    // Function for the tenant to make a security deposit
    public fun make_deposit(account: &signer,tenant: &signer, landlord: address, deposit_amount: u64) {
        let deposit = RentalDeposit {
            tenant: signer::address_of(tenant),
            deposit_amount,
        };
        move_to(account, deposit);

        coin::transfer<AptosCoin>(tenant, landlord, deposit_amount);
    }

    // Function for the landlord to refund or deduct from the deposit
    public fun manage_deposit(landlord: &signer, tenant: address, refund_amount: u64) acquires RentalDeposit {
        let deposit = borrow_global_mut<RentalDeposit>(tenant);

        // Ensure the refund amount is not more than the deposit
        assert!(refund_amount <= deposit.deposit_amount, 1);

        // Transfer the refund amount back to the tenant
        coin::transfer<AptosCoin>(landlord, tenant, refund_amount);

        // Deduct the refunded amount from the deposit
        deposit.deposit_amount = deposit.deposit_amount - refund_amount;
    }
}
