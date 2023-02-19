#![no_std]

use ink_lang::contract;

#[contract]
mod deposit_withdrawal {
    use ink_storage::collections::HashMap;
    use ink_prelude::vec::Vec;

    #[ink(storage)]
    pub struct DepositWithdrawal {
        balances: HashMap<AccountId, Balance>,
    }

    #[ink(event)]
    pub struct Deposit {
        #[ink(topic)]
        from: AccountId,
        amount: Balance,
    }

    #[ink(event)]
    pub struct Withdrawal {
        #[ink(topic)]
        to: AccountId,
        amount: Balance,
    }

    impl DepositWithdrawal {
        #[ink(constructor)]
        pub fn new() -> Self {
            Self {
                balances: HashMap::new(),
            }
        }

        #[ink(message)]
        pub fn deposit(&mut self) -> bool {
            let caller = self.env().caller();
            let value = self.env().transferred_balance();

            let balance = self.balances.entry(caller).or_insert(0);
            *balance += value;

            self.env().emit_event(Deposit {
                from: caller,
                amount: value,
            });

            true
        }

        #[ink(message)]
        pub fn withdraw(&mut self, amount: Balance) -> bool {
            let caller = self.env().caller();

            let balance = self.balances.get_mut(&caller).unwrap_or(&mut 0);

            if *balance < amount {
                return false;
            }

            *balance -= amount;

            self.env().transfer(caller, amount).expect("transfer failed");

            self.env().emit_event(Withdrawal {
                to: caller,
                amount,
            });

            true
        }

        #[ink(message)]
        pub fn get_balance(&self, account: AccountId) -> Balance {
            *self.balances.get(&account).unwrap_or(&0)
        }

        #[ink(message)]
        pub fn get_all_balances(&self) -> Vec<(AccountId, Balance)> {
            self.balances.iter().map(|(&k, &v)| (k, v)).collect()
        }
    }
}
