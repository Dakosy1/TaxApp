import UIKit
import SnapKit

class VATCalculatorViewController: UIViewController {
    
    // MARK: - Scroll & Content
    private lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        return sv
    }()
    
    private lazy var contentView = UIView()
    
    // MARK: - Segmented Control for VAT Mode
    private enum VATMode {
        case exclusive
        case inclusive
    }

    private var selectedVATMode: VATMode = .exclusive // Default to Exclusive

    private lazy var vatExclusiveRadioButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("VATExclusive", comment: "VAT Exclusive"), for: .normal)
        button.setImage(UIImage(systemName: "circle.inset.filled"), for: .normal)
        button.tintColor = .systemBlue
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.contentHorizontalAlignment = .left
        button.addTarget(self, action: #selector(vatExclusiveTapped), for: .touchUpInside)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
        return button
    }()

    private lazy var vatInclusiveRadioButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("VATInclusive", comment: "VAT Inclusive"), for: .normal)
        button.setImage(UIImage(systemName: "circle"), for: .normal)
        button.tintColor = .systemBlue
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.contentHorizontalAlignment = .left
        button.addTarget(self, action: #selector(vatInclusiveTapped), for: .touchUpInside)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
        return button
    }()

    private lazy var vatModeStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [vatExclusiveRadioButton, vatInclusiveRadioButton])
        stack.axis = .horizontal
        stack.spacing = 16
        stack.alignment = .center
        stack.distribution = .fillProportionally
        return stack
    }()
    
    // MARK: - Labels
    private lazy var amountLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Amount", comment: "Amount label")
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        return label
    }()
    
    private lazy var vatRateLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("VAT", comment: "VAT label")
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        return label
    }()
    
    // MARK: - Input Fields
    private lazy var amountTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = NSLocalizedString("EnterAmount", comment: "Enter amount placeholder")
        tf.borderStyle = .roundedRect
        tf.keyboardType = .decimalPad
        tf.delegate = self
        
        let iconView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        iconView.image = UIImage(systemName: "dollarsign.circle")
        iconView.tintColor = .systemBlue
        iconView.contentMode = .scaleAspectFit
        tf.leftView = iconView
        tf.leftViewMode = .always
        return tf
    }()
    
    private lazy var vatRateTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = NSLocalizedString("EnterVATRate", comment: "Enter VAT rate placeholder")
        tf.borderStyle = .roundedRect
        tf.keyboardType = .decimalPad
        tf.delegate = self
        
        let iconView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        iconView.image = UIImage(systemName: "percent")
        iconView.tintColor = .systemBlue
        iconView.contentMode = .scaleAspectFit
        tf.leftView = iconView
        tf.leftViewMode = .always
        return tf
    }()
    
    // MARK: - Buttons
    private lazy var calculateButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("Calculator", comment: "Calculator button"), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(calculateButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var resetButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("Reset", comment: "Reset button"), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        button.backgroundColor = .systemRed
        button.layer.cornerRadius = 12
        button.isHidden = true
        button.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var buttonsStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [calculateButton, resetButton])
        stack.axis = .horizontal
        stack.spacing = 16
        stack.distribution = .fillEqually
        return stack
    }()
    
    // MARK: - Share Button
    private lazy var shareButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("Share", comment: "Share button"), for: .normal)
        button.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 12
        button.isHidden = true
        button.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
        return button
    }()
    
    // MARK: - Results View
    private lazy var resultView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.systemGray5.cgColor
        view.isHidden = true
        return view
    }()
    
    private lazy var resultTitleView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue
        view.layer.cornerRadius = 12
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return view
    }()
    
    private lazy var resultTitleLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("CalculationResult", comment: "Calculation Result title")
        label.textColor = .white
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var netAmountLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("NetAmount", comment: "Net Amount label")
        label.font = .systemFont(ofSize: 14)
        label.textColor = .systemGray
        return label
    }()
    
    private lazy var netAmountValueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .black
        label.textAlignment = .right
        return label
    }()
    
    private lazy var vatAmountLabel: UILabel = {
        let label = UILabel()
        label.text = "VAT (0.00%):"
        label.font = .systemFont(ofSize: 14)
        label.textColor = .systemGray
        return label
    }()
    
    private lazy var vatAmountValueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .black
        label.textAlignment = .right
        return label
    }()
    
    private lazy var grossAmountLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("GrossAmount", comment: "Gross Amount label")
        label.font = .systemFont(ofSize: 14)
        label.textColor = .systemGray
        return label
    }()
    
    private lazy var grossAmountValueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .black
        label.textAlignment = .right
        return label
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = NSLocalizedString("VATCalculatorTitle", comment: "VAT Calculator title")
        
        amountTextField.delegate = self
        vatRateTextField.delegate = self
        
        setupUI()
        setupKeyboardDismiss()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Add subviews
        [
            vatModeStack,
            amountLabel, amountTextField,
            vatRateLabel, vatRateTextField,
            buttonsStackView, resultView, shareButton
        ].forEach { contentView.addSubview($0) }
        
        resultView.addSubview(resultTitleView)
        resultTitleView.addSubview(resultTitleLabel)
        
        [
            netAmountLabel, netAmountValueLabel,
            vatAmountLabel, vatAmountValueLabel,
            grossAmountLabel, grossAmountValueLabel
        ].forEach { resultView.addSubview($0) }
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(view)
        }
        
        amountLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.left.right.equalToSuperview().inset(16)
        }
        
        vatModeStack.snp.makeConstraints { make in
            make.top.equalTo(amountLabel.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(40)
        }
        
        amountTextField.snp.makeConstraints { make in
            make.top.equalTo(vatModeStack.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(56)
        }
        
        vatRateLabel.snp.makeConstraints { make in
            make.top.equalTo(amountTextField.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(16)
        }
        
        vatRateTextField.snp.makeConstraints { make in
            make.top.equalTo(vatRateLabel.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(56)
        }
        
        buttonsStackView.snp.makeConstraints { make in
            make.top.equalTo(vatRateTextField.snp.bottom).offset(24)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(50)
        }
        
        resultView.snp.makeConstraints { make in
            make.top.equalTo(buttonsStackView.snp.bottom).offset(24)
            make.left.right.equalToSuperview().inset(16)
        }
        
        resultTitleView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(44)
        }
        
        resultTitleLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        netAmountLabel.snp.makeConstraints { make in
            make.top.equalTo(resultTitleView.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(16)
        }
        
        netAmountValueLabel.snp.makeConstraints { make in
            make.centerY.equalTo(netAmountLabel)
            make.right.equalToSuperview().offset(-16)
        }
        
        let dashedLine1 = addDashedLine(below: netAmountValueLabel, in: resultView, verticalSpacing: 8)
        
        vatAmountLabel.snp.makeConstraints { make in
            make.top.equalTo(netAmountLabel.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(16)
        }
        
        vatAmountValueLabel.snp.makeConstraints { make in
            make.centerY.equalTo(vatAmountLabel)
            make.right.equalToSuperview().offset(-16)
        }
        
        let dashedLine2 = addDashedLine(below: vatAmountValueLabel, in: resultView, verticalSpacing: 8)
        
        grossAmountLabel.snp.makeConstraints { make in
            make.top.equalTo(vatAmountLabel.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(-16)
        }
        
        grossAmountValueLabel.snp.makeConstraints { make in
            make.centerY.equalTo(grossAmountLabel)
            make.right.equalToSuperview().offset(-16)
        }
        
        let dashedLine3 = addDashedLine(below: grossAmountValueLabel, in: resultView, verticalSpacing: 8)
        
        shareButton.snp.makeConstraints { make in
            make.top.equalTo(resultView.snp.bottom).offset(24)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(50)
            make.bottom.equalToSuperview().offset(-20)
        }
    }
    
    private func setupKeyboardDismiss() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    private func addDashedLine(
        below topView: UIView,
        in container: UIView,
        horizontalInset: CGFloat = 16,
        verticalSpacing: CGFloat = 8
    ) -> UIView {
        let dashedLine = UIView()
        dashedLine.backgroundColor = .clear
        container.addSubview(dashedLine)
        
        dashedLine.snp.makeConstraints { make in
            make.top.equalTo(topView.snp.bottom).offset(verticalSpacing)
            make.left.right.equalToSuperview().inset(horizontalInset)
            make.height.equalTo(1)
        }
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor.systemGray3.cgColor
        shapeLayer.lineWidth = 1
        shapeLayer.lineDashPattern = [6, 4]
        dashedLine.layer.addSublayer(shapeLayer)
        
        dashedLine.layoutIfNeeded()
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0.5))
        path.addLine(to: CGPoint(x: dashedLine.bounds.width, y: 0.5))
        shapeLayer.path = path.cgPath
        shapeLayer.frame = dashedLine.bounds
        
        return dashedLine
    }
    
    // MARK: - Actions
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func calculateButtonTapped() {
        guard let amountText = amountTextField.text,
              let enteredAmount = Double(amountText),
              let vatRateText = vatRateTextField.text,
              let vatRate = Double(vatRateText),
              vatRate >= 0 else {
            return
        }
        
        vatAmountLabel.text = "VAT (\(String(format: "%.1f", vatRate))%):"
        
        var netAmount = 0.0
        var grossAmount = 0.0
        var vatValue = 0.0

        switch selectedVATMode {
        case .exclusive:
            netAmount = enteredAmount
            vatValue = netAmount * (vatRate / 100.0)
            grossAmount = netAmount + vatValue
        case .inclusive:
            grossAmount = enteredAmount
            netAmount = grossAmount / (1 + vatRate / 100.0)
            vatValue = grossAmount - netAmount
        }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        
        netAmountValueLabel.text = "\(formatter.string(from: NSNumber(value: netAmount)) ?? "0.00") $"
        vatAmountValueLabel.text = "\(formatter.string(from: NSNumber(value: vatValue)) ?? "0.00") $"
        grossAmountValueLabel.text = "\(formatter.string(from: NSNumber(value: grossAmount)) ?? "0.00") $"
        
        resultView.isHidden = false
        resetButton.isHidden = false
        shareButton.isHidden = false
    }
    
    @objc private func vatExclusiveTapped() {
        selectedVATMode = .exclusive
        updateRadioUI()
    }
    
    @objc private func vatInclusiveTapped() {
        selectedVATMode = .inclusive
        updateRadioUI()
    }

    private func updateRadioUI() {
        switch selectedVATMode {
        case .exclusive:
            vatExclusiveRadioButton.setImage(UIImage(systemName: "circle.inset.filled"), for: .normal)
            vatInclusiveRadioButton.setImage(UIImage(systemName: "circle"), for: .normal)
        case .inclusive:
            vatExclusiveRadioButton.setImage(UIImage(systemName: "circle"), for: .normal)
            vatInclusiveRadioButton.setImage(UIImage(systemName: "circle.inset.filled"), for: .normal)
        }
    }
    
    @objc private func resetButtonTapped() {
        amountTextField.text = nil
        vatRateTextField.text = nil
        selectedVATMode = .exclusive
        updateRadioUI()
        resultView.isHidden = true
        resetButton.isHidden = true
        shareButton.isHidden = true
        vatAmountLabel.text = "VAT (0.00%):"
    }

    @objc private func shareButtonTapped() {
        guard !resultView.isHidden else { return }
        
        let shareText = """
        VAT Calculation

        Net Amount (Excluding VAT): \(netAmountValueLabel.text ?? "")
        \(vatAmountLabel.text ?? "VAT:") \(vatAmountValueLabel.text ?? "")
        Gross Amount (Including VAT): \(grossAmountValueLabel.text ?? "")
        """
        
        let activityVC = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        
        if let popoverController = activityVC.popoverPresentationController {
            popoverController.sourceView = shareButton
            popoverController.sourceRect = shareButton.bounds
        }
        
        present(activityVC, animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension VATCalculatorViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.isEmpty {
            return true
        }
        
        let allowedCharacters = CharacterSet(charactersIn: "0123456789.")
        if string.rangeOfCharacter(from: allowedCharacters.inverted) != nil {
            return false
        }
        
        if string.contains(".") {
            if textField.text?.contains(".") == true {
                return false
            }
        }
        
        return true
    }
}
