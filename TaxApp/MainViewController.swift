import UIKit
import SnapKit

class MainViewController: UIViewController {
    
    // MARK: - UI Elements
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        return view
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 16
        layout.minimumLineSpacing = 16
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .white
        return cv
    }()
    
    private let services = [
        ServiceModel(
            title: NSLocalizedString("Individual Entrepreneur Tax", comment: "IE Tax Calculator"),
            imageName: "person.fill.badge.plus",
            tintColor: .systemGreen
        ),
        ServiceModel(
            title: NSLocalizedString("VAT, CIT & Social Payments", comment: "VAT, CIT, Social Calculator"),
            imageName: "doc.text.magnifyingglass",
            tintColor: .systemBlue
        ),
        ServiceModel(
            title: NSLocalizedString("Payment Deadlines", comment: "Tax Payment Deadlines"),
            imageName: "calendar.badge.clock",
            tintColor: .systemOrange
        ),
        ServiceModel(
            title: NSLocalizedString("StopThreat", comment: "Service Stop Threat"),
            imageName: "exclamationmark.shield.fill",
            tintColor: .systemRed
        ),
        ServiceModel(
            title: NSLocalizedString("Popular", comment: "Service Popular"),
            imageName: "star.fill",
            tintColor: .systemOrange
        ),
        ServiceModel(
            title: NSLocalizedString("Assistants", comment: "Service Assistants"),
            imageName: "gearshape.fill",
            tintColor: .systemOrange
        )
    ]
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemGray6 // Слегка серый фон
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ServiceCell.self, forCellWithReuseIdentifier: ServiceCell.reuseIdentifier)
        
        view.addSubview(containerView)
        containerView.addSubview(collectionView)
        
        containerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(150)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(286) // Высота для 2 строк с отступами
        }
        
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
    }
    
    private func setupNavigationBar() {
        // Кнопка профиля слева
        let profileButton = UIBarButtonItem(
            image: UIImage(systemName: "person.circle"),
            style: .plain,
            target: self,
            action: #selector(profileButtonTapped)
        )
        
        navigationItem.leftBarButtonItem = profileButton
        
        // Кнопка QR-кода
        let qrButton = UIBarButtonItem(
            image: UIImage(systemName: "qrcode"),
            style: .plain,
            target: self,
            action: #selector(qrButtonTapped)
        )
        
        // Кнопка "О нас"
        let infoButton = UIBarButtonItem(
            image: UIImage(systemName: "info.circle"),
            style: .plain,
            target: self,
            action: #selector(infoButtonTapped)
        )
        
        navigationItem.rightBarButtonItems = [infoButton, qrButton]
    }
    
    // MARK: - Actions
    @objc private func profileButtonTapped() {
        let profileVC = ProfileViewController()
        navigationController?.pushViewController(profileVC, animated: true)
    }
    
    @objc private func qrButtonTapped() {
        let qrVC = UIViewController()
        qrVC.view.backgroundColor = .white
        qrVC.title = NSLocalizedString("QRCode", comment: "QR Code title")
        navigationController?.pushViewController(qrVC, animated: true)
    }
    
    @objc private func infoButtonTapped() {
        let infoVC = UIViewController()
        infoVC.view.backgroundColor = .white
        infoVC.title = NSLocalizedString("AboutUs", comment: "About Us title")
        navigationController?.pushViewController(infoVC, animated: true)
    }
}

// MARK: - Collection View Data Source & Delegate
extension MainViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return services.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ServiceCell.reuseIdentifier, for: indexPath) as! ServiceCell
        let service = services[indexPath.item]
        cell.configure(with: service)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 32) / 3 // 3 элемента в строке, с учётом отступов
        return CGSize(width: width, height: width * 1.2)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let service = services[indexPath.item]
        
        let destinationVC: UIViewController
        
        switch indexPath.item {
        case 0:
            destinationVC = IPCalculatorViewController()
        case 1:
            destinationVC = VATCalculatorViewController()
        case 2:
            destinationVC = TaxDeadlinesViewController()
        case 3:
            destinationVC = StopThreatViewController()
        case 4:
            destinationVC = PopularViewController()
        case 5:
            destinationVC = AssistantsViewController()
        default:
            return
        }
        
        destinationVC.title = service.title
        navigationController?.pushViewController(destinationVC, animated: true)
    }

}

// MARK: - Service Model
struct ServiceModel {
    let title: String
    let imageName: String
    let tintColor: UIColor
}

// MARK: - Service Cell
class ServiceCell: UICollectionViewCell {
    static let reuseIdentifier = "ServiceCell"
    
    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 12)
        label.textColor = .label
        label.numberOfLines = 2
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        contentView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        
        iconImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(12)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(40)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(iconImageView.snp.bottom).offset(8)
            make.leading.trailing.bottom.equalToSuperview().inset(4)
        }
    }
    
    func configure(with service: ServiceModel) {
        titleLabel.text = service.title
        let config = UIImage.SymbolConfiguration(pointSize: 30)
        let image = UIImage(systemName: service.imageName, withConfiguration: config)
        iconImageView.image = image
        iconImageView.tintColor = service.tintColor
        contentView.backgroundColor = .clear
    }
}


//class IndividualEntrepreneurTaxViewController: UIViewController {
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .systemBackground
//        // Добавь интерфейс расчёта ИП-налога здесь
//    }
//}

class VatCITSocialCalculatorViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        // Добавь калькулятор НДС, КПН и соц. отчислений здесь
    }
}

class TaxDeadlinesViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        // Добавь отображение сроков уплаты и сумм здесь
    }
}


class StopThreatViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
    }
}

class PopularViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
    }
}

class AssistantsViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
    }
}
