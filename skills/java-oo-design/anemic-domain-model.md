# Anemic Domain Model

An anemic domain is a bag of data: fields, getters, setters, with every rule living in a `Service`. It looks organized, but it trades encapsulation for procedural code wearing dependency injection as a disguise.

```java
// AVOID: state exposed, behavior elsewhere
class BankAccount {
    private BigDecimal balance;
    public void setBalance(BigDecimal balance) { this.balance = balance; }
    public BigDecimal getBalance() { return balance; }
}

class AccountService {
    void withdraw(BankAccount account, BigDecimal amount) {
        account.setBalance(account.getBalance().subtract(amount));
    }
}

// USE: state protected, behavior inside
class BankAccount {
    private BigDecimal balance;

    public void withdraw(BigDecimal amount) {
        if (amount.compareTo(balance) > 0) throw new InsufficientBalanceException();
        this.balance = balance.subtract(amount);
    }
}
```

**The public setter is the dangerous symptom.** It exposes the internal representation and permits invalid states at any moment: today a negative balance, tomorrow a status that skips a step. An invariant that should be guaranteed in one place becomes an informal agreement across dozens of call sites.

## The review signal

A method that works only with its parameters and never touches its own instance fields. That is an artificial separation between state and behavior — the logic belongs on the class holding the data.

**If you need a getter to make a decision and a setter to apply the result, the behavior belongs inside the class.**

## Where it does not apply

Spring Boot controllers are stateless by design, to serve requests in parallel. That does not contradict the rule, it locates it: the controller coordinates, the domain protects invariants.

Getters required by persistence or serialization are also fine — the problem is a getter that exists so someone else can make the decision.

## Red flags

- A `Service`/`Manager` whose methods only get-compute-set on an argument
- A public setter on a field with an invariant
- A domain class with no method that expresses a business action
- The same validation before every call to a setter
