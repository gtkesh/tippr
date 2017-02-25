//
//  ViewController.swift
//  tippr
//
//  Created by Giorgi Tkeshelashvili on 2/24/17.
//  Copyright © 2017 Giorgi Tkeshelashvili. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

    // MARK: - IBOutlets
    
    @IBOutlet weak var initialAmountTextField: UITextField!
    @IBOutlet weak var tipPercentageSegmentView: UISegmentedControl!
    @IBOutlet weak var tipAmountLabel: UILabel!
    @IBOutlet weak var totalAmountLabel: UILabel!


    // MARK: - Properties
    
    var currentTipPercent: NSDecimalNumber {
        return percentOptions[tipPercentageSegmentView.selectedSegmentIndex]
    }
    
    // MARK: - Constants

    let percentOptions: [NSDecimalNumber] = [0.15, 0.2, 0.25]

    /// A formatter which uses currency style
    let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initialAmountTextField.delegate = self
        initialAmountTextField.becomeFirstResponder()

        for (index, value) in percentOptions.enumerated() {
            tipPercentageSegmentView.setTitle("\(value.multiplying(by: 100).intValue)%", forSegmentAt: index)
        }
    }

    @IBAction func didTapSegmentControl(_ sender: UISegmentedControl) {
        updateInitialValue(from: initialAmountTextField.text!)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        var replacementString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        
        if replacementString == "$" {
            textField.text = ""
            tipAmountLabel.text = currencyFormatter.string(from: 0)
            totalAmountLabel.text = currencyFormatter.string(from: 0)
            return false
        } else if replacementString.characters.first != "$" {
            if replacementString == "0" {
                return false
            }
            replacementString = "$" + replacementString
        }
        

        guard let _ = currencyFormatter.number(from: replacementString)?.decimalValue else {
            return false
        }
        if replacementString.components(separatedBy: ".").count == 2 {
            if replacementString.components(separatedBy: ".")[1].characters.count > 2 {
                return false
            }
        }
        
        updateInitialValue(from: replacementString)
        
        textField.text = replacementString
        
        return false
    }

    func updateInitialValue(from valueString: String) {

        guard let decimalValue = currencyFormatter.number(from: valueString)?.decimalValue else {
            return
        }

        let initialDecimal = NSDecimalNumber(decimal: decimalValue)
        let tipAmount = initialDecimal.multiplying(by: currentTipPercent)
        let totalAmount = initialDecimal.adding(tipAmount)

        tipAmountLabel.text = currencyFormatter.string(from: tipAmount)
        totalAmountLabel.text = currencyFormatter.string(from: totalAmount)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
