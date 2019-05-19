//
//  Copyright © 2019 An Tran. All rights reserved.
//

import RxSwift
import RxCocoa
import Kingfisher
import UIKit

class ImageListViewController: ViewController {

    // MARK: Properties

    @IBOutlet weak var searchTermTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!

    let disposeBag = DisposeBag()

    // MARK: Setup ViewModel

    lazy var viewModel = ImageListViewModel(service: context.pixelBayService)

    // MARK: Lifecyles

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self

        searchTermTextField.rx.text
            .orEmpty
            .bind(to: viewModel.searchTerm)
            .disposed(by: disposeBag)

        viewModel.imageList.subscribe(
            onNext: { imageList in
                self.tableView.reloadData()
            }
        ).disposed(by: disposeBag)

        tableView.register(UINib(nibName: "ImageListTableViewCell", bundle: nil), forCellReuseIdentifier: "ImageListTableViewCell")

        title = "List"
    }
}

extension ImageListViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.imageList.value.hits.count
    }
}

extension ImageListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ImageListTableViewCell = tableView.dequeueReusableCell(withIdentifier: "ImageListTableViewCell") as! ImageListTableViewCell

        let imageItem = viewModel.imageList.value.hits[indexPath.row]
        cell.titleLabel?.text = imageItem.previewURL
        guard let url = URL(string: imageItem.previewURL) else {
            return cell
        }

        cell.previewImageView.kf.setImage(with: url)

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let imageItem = viewModel.imageList.value.hits[indexPath.row]
        let detailViewController = ImageDetailViewController(context: context, image: imageItem)
        navigationController?.pushViewController(detailViewController, animated: true)
    }
}
