import UIKit
import SnapKit

class IPCalculatorViewController: UIViewController {
    
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        return sv
    }()
    
    private let contentView = UIView()
    
    private let incomeTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Введите доход"
        tf.borderStyle = .roundedRect
        tf.keyboardType = .numberPad
        tf.font = .systemFont(ofSize: 16)
        tf.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return tf
    }()
    
    private let taxTypeLabel: UILabel = {
        let label = UILabel()
        label.text = "Режим налогообложения"
        label.textColor = .gray
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private let taxTypeSegmentControl: UISegmentedControl = {
        let items = ["Общеустановленный", "Упрощенный"]
        let sc = UISegmentedControl(items: items)
        sc.selectedSegmentIndex = 0
        return sc
    }()
    
    private let deductionsLabel: UILabel = {
        let label = UILabel()
        label.text = "Дополнительно"
        label.textColor = .gray
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private let deductionsStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 32
        return sv
    }()
    
    private let calculateButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Подсчитать", for: .normal)
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
    
    private var astanaHubSwitch: UISwitch?
    private var hasEmployeesSwitch: UISwitch?
    
    private let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        formatter.groupingSize = 3
        return formatter
    }()
    
    private func formatNumber(_ number: Double) -> String {
        return numberFormatter.string(from: NSNumber(value: number)) ?? "0"
    }
    
    private func formatInput(_ input: String) -> String {
        // Удаляем все пробелы и нечисловые символы
        let cleanNumber = input.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        
        // Конвертируем в число и обратно для форматирования
        if let number = Double(cleanNumber) {
            return formatNumber(number)
        }
        return input
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupKeyboardHandling()
        setupTextFieldDelegate()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Калькулятор ИП"
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        [incomeTextField, taxTypeLabel, taxTypeSegmentControl, deductionsLabel, deductionsStackView, calculateButton, resultsStackView].forEach {
            contentView.addSubview($0)
        }
        
        setupDeductionsStackView()
        setupConstraints()
        setupActions()
    }
    
    private func setupDeductionsStackView() {
        let deductions = [
            ("Участник Астана Хаб", UISwitch()),
            ("Есть наемные работники", UISwitch())
        ]
        
        for (index, (title, switch_)) in deductions.enumerated() {
            let containerView = UIView()
            let label = UILabel()
            label.text = title
            
            containerView.addSubview(label)
            containerView.addSubview(switch_)
            
            if index == 0 {
                astanaHubSwitch = switch_
            } else {
                hasEmployeesSwitch = switch_
            }
            
            switch_.addTarget(self, action: #selector(switchValueChanged(_:)), for: .valueChanged)
            
            label.translatesAutoresizingMaskIntoConstraints = false
            switch_.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                label.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                label.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
                
                switch_.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                switch_.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
            ])
            
            deductionsStackView.addArrangedSubview(containerView)
        }
    }
    
    private func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        incomeTextField.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        taxTypeLabel.snp.makeConstraints { make in
            make.top.equalTo(incomeTextField.snp.bottom).offset(24)
            make.leading.equalToSuperview().offset(16)
        }
        
        taxTypeSegmentControl.snp.makeConstraints { make in
            make.top.equalTo(taxTypeLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        deductionsLabel.snp.makeConstraints { make in
            make.top.equalTo(taxTypeSegmentControl.snp.bottom).offset(24)
            make.leading.equalToSuperview().offset(16)
        }
        
        deductionsStackView.snp.makeConstraints { make in
            make.top.equalTo(deductionsLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        calculateButton.snp.makeConstraints { make in
            make.top.equalTo(deductionsStackView.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        resultsStackView.snp.makeConstraints { make in
            make.top.equalTo(calculateButton.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-20)
        }
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
    
    private func setupActions() {
        calculateButton.addTarget(self, action: #selector(calculateTapped), for: .touchUpInside)
    }
    
    private func setupTextFieldDelegate() {
        incomeTextField.delegate = self
    }
    
    private func updateResults(ipn: Double, opv: Double, osms: Double, total: Double) {
        resultsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let results = [
            ("ИПН (10%)", ipn),
            ("ОПВ (10%)", opv),
            ("ОСМС (5%)", osms),
            ("Итого к оплате", total)
        ]
        
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
    
    @objc private func switchValueChanged(_ sender: UISwitch) {
        if sender == astanaHubSwitch && sender.isOn {
            hasEmployeesSwitch?.setOn(false, animated: true)
        }
        else if sender == hasEmployeesSwitch && sender.isOn {
            astanaHubSwitch?.setOn(false, animated: true)
        }
    }
    
    @objc private func calculateTapped() {
        guard let incomeText = incomeTextField.text?.components(separatedBy: CharacterSet.decimalDigits.inverted).joined(),
              let income = Double(incomeText) else { 
            showAlert(message: "Пожалуйста, введите корректный доход")
            return 
        }
        
        let isSimplified = taxTypeSegmentControl.selectedSegmentIndex == 1
        let isAstanaHub = astanaHubSwitch?.isOn ?? false
        let hasEmployees = hasEmployeesSwitch?.isOn ?? false
        
        var ipn = income * 0.1
        var opv = income * 0.1
        var osms = income * 0.05
        
        if isAstanaHub {
            ipn = 0
            opv = 0
            osms = 0
        }
        
        if isSimplified {
            ipn = income * 0.03
        }
        
        if hasEmployees {
            osms = income * 0.1
        }
        
        let total = ipn + opv + osms
        
        updateResults(ipn: ipn, opv: opv, osms: osms, total: total)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Внимание", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension IPCalculatorViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == incomeTextField {
            // Разрешаем удаление символов
            if string.isEmpty {
                return true
            }
            
            // Проверяем, что вводятся только цифры
            if CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: string)) {
                // Получаем текущий текст и новый текст после вставки
                let currentText = textField.text ?? ""
                guard let stringRange = Range(range, in: currentText) else { return false }
                let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
                
                // Форматируем число и обновляем текстовое поле
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
