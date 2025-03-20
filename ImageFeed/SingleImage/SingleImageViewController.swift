import UIKit

final class SingleImageViewController: UIViewController {

    // MARK: - Private Properties

    private let fullImageUrl: String

    private var imageView: UIImageView = UIImageView()
    private lazy var backButton: UIButton = {
        let backButtonImage = UIImage(named: "nav_back_button_white")?.withRenderingMode(.alwaysOriginal) ?? UIImage()
        let backButton = UIButton.systemButton(with: backButtonImage, target: self, action: #selector(Self.didTapBackButton))
        backButton.accessibilityIdentifier = AccessibilityIdentifiers.singleImageBackButton
        view.insertSubview(backButton, aboveSubview: scrollView)
        return backButton
    }()
    private lazy var shareButton: UIButton = {
        let shareButtonImage = UIImage(named: "share_button")?.withRenderingMode(.alwaysOriginal) ?? UIImage()
        let shareButton = UIButton.systemButton(with: shareButtonImage, target: self, action: #selector(Self.didTapShareButton))
        view.addSubview(shareButton)
        return shareButton
    }()
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.delegate = self
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 3

        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        return scrollView
    }()

    // MARK: - View Life Cycles

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack

        setupConstraints()
        loadImage()
    }
    // MARK: - Initializers

    init(fullImageUrl: String) {
        self.fullImageUrl = fullImageUrl
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private Methods

    @objc private func didTapBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @objc private func didTapShareButton(_ sender: Any) {
        guard let image = imageView.image else { return }
        present(UIActivityViewController(activityItems: [image], applicationActivities: nil), animated: true, completion: nil)
    }

    private func setupConstraints() {

        backButton.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        shareButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            backButton.widthAnchor.constraint(equalToConstant: 48),
            backButton.heightAnchor.constraint(equalToConstant: 48),
            backButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 9),
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 11),

            shareButton.widthAnchor.constraint(equalToConstant: 51),
            shareButton.heightAnchor.constraint(equalToConstant: 51),
            shareButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            shareButton.bottomAnchor.constraint(equalTo: view.bottomAnchor,constant: -50),
            shareButton.topAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.topAnchor),

            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),

        ])
    }


    private func rescaleAndCenterImageInScrollView(image: UIImage) {

        view.layoutIfNeeded()

        let scrollViewSize = scrollView.bounds.size
        let imageSize = image.size

        let scale = scrollViewSize.width / imageSize.width
        let newHeight = imageSize.height * scale

        imageView.frame = CGRect(origin: .zero, size: CGSize(width: scrollViewSize.width, height: newHeight))
        scrollView.contentSize = imageView.frame.size

        updateContentInset()
    }

    private func updateContentInset() {

        let scrollViewSize = scrollView.bounds.size
        let contentSize = scrollView.contentSize

        let horizontalInset = max(0, (scrollViewSize.width - contentSize.width) / 2)
        let verticalInset = max(0, (scrollViewSize.height - contentSize.height) / 2)

        scrollView.contentInset = UIEdgeInsets(top: verticalInset, left: horizontalInset, bottom: verticalInset, right: horizontalInset)
    }

    private func loadImage() {
        guard let url = URL(string: fullImageUrl) else { return }

        UIBlockingProgressHUD.show()
        imageView.kf.setImage(with: url) { [weak self] result in
            UIBlockingProgressHUD.dismiss()

            guard let self = self else { return }
            switch result {
            case .success(let imageResult):
                self.imageView.frame.size = imageResult.image.size
                self.rescaleAndCenterImageInScrollView(image: imageResult.image)

            case .failure:
                self.showError()
            }
        }
    }

    private func showError() {
        let alert = UIAlertController(title: "Что-то пошло не так", message: "Попробовать ещё раз?", preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: "Не надо", style: .cancel, handler: nil)
        let retryAction = UIAlertAction(title: "Повторить", style: .default) { [weak self] _ in
            self?.loadImage()
        }

        alert.addAction(cancelAction)
        alert.addAction(retryAction)

        present(alert, animated: true, completion: nil)
    }

}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateContentInset()
    }
}
