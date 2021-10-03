import Vapor

func routes(_ app: Application) throws {
    app.get { req in
        return req.view.render("index", ["title": "Hello Vapor!"])
    }

    app.get("hello") { req -> String in
        return "Hello, world!"
    }
    
    app.post("bill", "total") { req -> TotalBill in
        let bill = try req.content.decode(Bill.self)
        guard bill.amount > 0 else {
            return TotalBill(amount: bill.amount, tipPercentage: bill.tipPercentage,
                             tip: 0, total: 0)
        }
        guard bill.tipPercentage > 0 else {
            return TotalBill(amount: bill.amount, tipPercentage: bill.tipPercentage,
                             tip: 0, total: bill.amount)
        }
        var calculatedTip = bill.amount * bill.tipPercentage / 100.0
        var roundedTip = Decimal()
        NSDecimalRound(&roundedTip, &calculatedTip, 2, .plain)  //Rounding to 2 decimal places
        
        let calculatedTotal = bill.amount + roundedTip
        
        let total = TotalBill(amount: bill.amount, tipPercentage: bill.tipPercentage,
                              tip: roundedTip, total: calculatedTotal)
        return total
    }
}

struct Bill: Content {
    let amount: Decimal
    let tipPercentage: Decimal
}

struct TotalBill: Content {
    let amount: Decimal
    let tipPercentage: Decimal
    let tip: Decimal
    let total: Decimal
}
