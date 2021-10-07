import Vapor

func routes(_ app: Application) throws {
    app.get { req in
        return req.view.render("index", ["title": "Hello Vapor!"])
    }

    app.get("hello") { req -> String in
        return "Hello, world!"
    }
    
    app.post("bill", "total") { req throws -> TotalBill in
        //Validate JSON data
        try Bill.validate(content: req)
        
        //Decode JSON Payload from request body
        let bill = try req.content.decode(Bill.self)
        
        //Calculate the tip based on the inputs provided
        var calculatedTip = bill.amount * bill.tipPercentage / 100.0
    
        //Rounding to 2 decimal places
        var roundedTip = Decimal()
        NSDecimalRound(&roundedTip, &calculatedTip, 2, .plain)
        
        let calculatedTotal = bill.amount + roundedTip
        
        let total = TotalBill(amount: bill.amount, tipPercentage: bill.tipPercentage,
                              tip: roundedTip, total: calculatedTotal)
        return total
    }
    
    //Render initial HTML page with default data
    app.get("bill") { req -> EventLoopFuture<View> in
        let bill = BillData(amount: 0, tipPercentage: 15.0, tip: 0, total: 0)
        return req.view.render("bill", bill)
    }
    
    //Receive form data, calculate tip and provide updated HTML page
    app.post("bill") { req -> EventLoopFuture<View> in
        try BillForm.validate(content: req)
        let billForm = try req.content.decode(BillForm.self)
        let calculatedTip = billForm.amount * billForm.tipPercentage / 100.0
        let calculatedTotal = billForm.amount + calculatedTip
        let bill = BillData(amount: billForm.amount, tipPercentage: billForm.tipPercentage, tip: calculatedTip, total: calculatedTotal)
        return req.view.render("bill", bill)
    }

}

struct Bill: Content {
    let amount: Decimal
    let tipPercentage: Decimal
}

extension Bill: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("amount", as: Decimal.self, is: .range(0.0...))
        validations.add("tipPercentage", as: Decimal.self, is: .range(0.0...100.0))
    }
}

struct TotalBill: Content {
    let amount: Decimal
    let tipPercentage: Decimal
    let tip: Decimal
    let total: Decimal
}


struct BillForm: Decodable {
    let amount: Double
    let tipPercentage: Double
}

extension BillForm: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("amount", as: Double.self, is: .range(0.0...))
        validations.add("tipPercentage", as: Double.self, is: .range(0.0...100.0))
    }
}

struct BillData: Encodable {
    let amount: Double
    let tipPercentage: Double
    let tip: Double
    let total: Double
}


