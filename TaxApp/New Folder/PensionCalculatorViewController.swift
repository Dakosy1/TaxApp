import UIKit
import SnapKit

class PensionCalculatorViewController: UIViewController {
    
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        return sv
    }()
    
    private let contentView = UIView()
    
    private let salaryTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Введите заработную плату"
        tf.borderStyle = .roundedRect
        tf.keyboardType = .numberPad
        tf.font = .systemFont(ofSize: 16)
        tf.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return tf
    }()
    
    private let typeSegmentControl: UISegmentedControl = {
        let items = ["Работник", "Работодатель"]
        let sc = UISegmentedControl(items: items)
        sc.selectedSegmentIndex = 0
        return sc
    }()
    
    private let calculateButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Рассчитать", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.layer.cornerRadius = 12
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return button
    }()
    
    private let resultsStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 12
        sv.isHidden = true
        return sv
    }()
    
    private let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        formatter.groupingSize = 3
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupKeyboardHandling()
        setupTextFieldDelegate()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Пенсионный калькулятор"
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        [salaryTextField, typeSegmentControl, calculateButton, resultsStackView].forEach {
            contentView.addSubview($0)
        }
        
        setupConstraints()
        setupActions()
    }
    
    private func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        salaryTextField.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        typeSegmentControl.snp.makeConstraints { make in
            make.top.equalTo(salaryTextField.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        calculateButton.snp.makeConstraints { make in
            make.top.equalTo(typeSegmentControl.snp.bottom).offset(32)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        resultsStackView.snp.makeConstraints { make in
            make.top.equalTo(calculateButton.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-20)
        }
    }
    
    private func setupActions() {
        calculateButton.addTarget(self, action: #selector(calculateTapped), for: .touchUpInside)
    }
    
    private func setupTextFieldDelegate() {
        salaryTextField.delegate = self
    }
    
    private func setupKeyboardHandling() {
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        scrollView.contentInset.bottom = keyboardSize.height
        scrollView.scrollIndicatorInsets = scrollView.contentInset
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset.bottom = 0
        scrollView.scrollIndicatorInsets = scrollView.contentInset
    }
    
    private func formatNumber(_ number: Double) -> String {
        return numberFormatter.string(from: NSNumber(value: number)) ?? "0"
    }
    
    private func updateResults(opv: Double, vpn: Double?, total: Double) {
        resultsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        var results: [(String, Double)] = [
            ("ОПВ (10%)", opv)
        ]
        
        if let vpn = vpn {
            results.append(("ВПН (5%)", vpn))
        }
        
        results.append(("Итого", total))
        
        for (title, value) in results {
            let resultView = UIView()
            resultView.backgroundColor = .systemGray6
            resultView.layer.cornerRadius = 12
            
            let titleLabel = UILabel()
            titleLabel.text = title
            titleLabel.textColor = .gray
            
            let valueLabel = UILabel()
            valueLabel.text = "\(formatNumber(value)) ₸"
            valueLabel.font = .systemFont(ofSize: 17, weight: .semibold)
            
            resultView.addSubview(titleLabel)
            resultView.addSubview(valueLabel)
            
            titleLabel.snp.makeConstraints { make in
                make.leading.equalToSuperview().offset(16)
                make.centerY.equalToSuperview()
            }
            
            valueLabel.snp.makeConstraints { make in
                make.trailing.equalToSuperview().offset(-16)
                make.centerY.equalToSuperview()
            }
            
            resultView.snp.makeConstraints { make in
                make.height.equalTo(50)
            }
            
            resultsStackView.addArrangedSubview(resultView)
        }
        
        resultsStackView.isHidden = false
    }
    
    @objc private func calculateTapped() {
        guard let salaryText = salaryTextField.text?.components(separatedBy: CharacterSet.decimalDigits.inverted).joined(),
              let salary = Double(salaryText) else {
            showAlert(message: "Пожалуйста, введите корректную сумму")
            return
        }
        
        let isEmployee = typeSegmentControl.selectedSegmentIndex == 0
        let opv = salary * 0.1
        var vpn: Double? = nil
        
        if isEmployee {
            vpn = salary * 0.05
        }
        
        let total = opv + (vpn ?? 0)
        updateResults(opv: opv, vpn: vpn, total: total)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Внимание", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension PensionCalculatorViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == salaryTextField {
            if string.isEmpty {
                return true
            }
            
            if CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: string)) {
                let currentText = textField.text ?? ""
                guard let stringRange = Range(range, in: currentText) else { return false }
                let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
                
                let cleanNumber = updatedText.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
                if let number = Double(cleanNumber) {
                    textField.text = formatNumber(number)
                }
            }
            return false
        }
        return true
    }
} 