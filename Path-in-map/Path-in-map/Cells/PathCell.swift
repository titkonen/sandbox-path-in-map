import UIKit

class PathCell: UITableViewCell {
    
    // MARK: Properties
    var runData: Path? {
        didSet {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yy hh:mm"
            noteTitle.text = String(format: "%.1f",runData?.distance ?? 0) + " m"
            previewLabel.text = String(runData?.duration ?? 0) + " sec"
            dateLabel.text = dateFormatter.string(from: runData?.timestamp ?? Date())
            ///print("Cell DidSet called \(runData?.distance ?? 1)")
        }
    }
    
    var paikkaData: Paikka? {
        didSet {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yy hh:mm"
            dateLabelLocation.text = dateFormatter.string(from: paikkaData?.timestamp ?? Date())
            print("Paikka timeStamp called \(paikkaData?.timestamp ?? Date())")
            print("Paikka latitude called \(paikkaData?.latitude)")
        }
    }
    
    // MARK: PROTOTYPING LOCATION DATA
    /// Date label
    fileprivate var dateLabelLocation: UILabel = {
        let label = UILabel()
        label.text = "4/6/2019"
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = UIColor.white.withAlphaComponent(0.5)
        return label
    }()
  
    /// Note title = Distance
    fileprivate var noteTitle: UILabel = {
        let label = UILabel()
        label.text = "Places to take photos"
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .white
        return label
    }()

    /// Date label
    fileprivate var dateLabel: UILabel = {
        let label = UILabel()
        label.text = "4/6/2019"
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = UIColor.white.withAlphaComponent(0.5)
        return label
    }()
        
    /// Preview label = Duration
    fileprivate var previewLabel: UILabel = {
        let label = UILabel()
        label.text = "The note text will go here for note preview..."
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .white
        //label.textColor = UIColor.gray.withAlphaComponent(0.8)
        return label
    }()
    
    /// horizontal stack view
    fileprivate lazy var horizontalStackView: UIStackView = {
        let s = UIStackView(arrangedSubviews: [noteTitle, previewLabel, UIView()])
        s.axis = .horizontal
        s.spacing = 20
        s.alignment = .leading
        return s
    }()
    
    /// vertical stack view
    fileprivate lazy var verticalStackView: UIStackView = {
        let s = UIStackView(arrangedSubviews: [dateLabel, horizontalStackView])
        s.axis = .vertical
        s.spacing = 5
        
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = UIColor(red: 2/255, green: 89/255, blue: 89/255, alpha: 1)
        contentView.addSubview(verticalStackView)
        verticalStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        verticalStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        verticalStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    // MARK: Helpers
//    func configure(for path: Path) {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "MM/dd/yy hh:mm"
//        noteTitle.text = String(format: "%.1f",path.distance) + " m"
//        previewLabel.text = String(path.duration) + " sec"
//        dateLabel.text = dateFormatter.string(from: path.timestamp ?? Date())
//    }
    
}


