import UIKit

final class SingleImageViewController: UIViewController {

    // MARK: - Public Properties

    var image: UIImage? {
        didSet {
            guard isViewLoaded, let image ,let imageView else { return }

            imageView.image = image
            imageView.frame.size = image.size
            rescaleAndCenterImageInScrollView(image: image)
        }
    }

    // MARK: - Private Properties

    private var imageView: UIImageView?
    private var backButton: UIButton?
    private var shareButton: UIButton?
    private var scrollView: UIScrollView?

    // MARK: - View Life Cycles

    override func viewDidLoad() {
        super.viewDidLoad()

        initViews()
        addSubviews()
        setupConstraints()

        guard
            let imageView,
            let image = image
        else { return }

        imageView.frame.size = image.size
        rescaleAndCenterImageInScrollView(image: image)
    }

    // MARK: - Private Methods

    @objc private func didTapBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @objc private func didTapShareButton(_ sender: Any) {
        guard let image else { return }
        present(UIActivityViewController(activityItems: [image], applicationActivities: nil), animated: true, completion: nil)
    }

    private func addSubviews() {
        guard
            let imageView,
            let backButton,
            let scrollView,
            let shareButton
        else { return }

        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        view.addSubview(backButton)
        view.addSubview(shareButton)
    }

    private func setupConstraints() {
        guard
            let backButton,
            let scrollView,
            let shareButton
        else { return }

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

    private func initViews() {
        self.view.backgroundColor = .ypBlack

        let scrollView = UIScrollView()
        scrollView.delegate = self
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25

        let imageView = UIImageView()
        guard let image = image else { return }
        imageView.image = image

        let backButtonImage = UIImage(named: "nav_back_button_white")?.withRenderingMode(.alwaysOriginal) ?? UIImage()
        let backButton = UIButton.systemButton(with: backButtonImage, target: self, action: #selector(Self.didTapBackButton))

        let shareButtonImage = UIImage(named: "share_button")?.withRenderingMode(.alwaysOriginal) ?? UIImage()
        let shareButton = UIButton.systemButton(with: shareButtonImage, target: self, action: #selector(Self.didTapShareButton))

        self.backButton = backButton
        self.scrollView = scrollView
        self.imageView = imageView
        self.shareButton = shareButton

    }

    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        guard let scrollView else { return }

        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()

        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, min(hScale, vScale)))

        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()

        updateContentInset()
    }

    private func updateContentInset() {
        guard let scrollView else { return }

        let scrollViewSize = scrollView.bounds.size
        let contentSize = scrollView.contentSize

        let horizontalInset = max(0, (scrollViewSize.width - contentSize.width) / 2)
        let verticalInset = max(0, (scrollViewSize.height - contentSize.height) / 2)

        scrollView.contentInset = UIEdgeInsets(top: verticalInset, left: horizontalInset, bottom: verticalInset, right: horizontalInset)
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
