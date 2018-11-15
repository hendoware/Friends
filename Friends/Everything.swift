//
//  ViewController.swift
//  Friends
//
//  Created by Sean Hendrix! on 11/15/18.
//  Copyright © 2018 Sean Hendrix! All rights reserved.
//

import UIKit

struct Friend {
    let name: String
    let image: UIImage
    let job: String
}

class NavigationControllerDelegate: NSObject, UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        guard let toVC = toVC as? DetailViewController else { return nil }
        
        toVC.loadViewIfNeeded()
        
        animator.sourceImageView = sourceCell.cellImageView
        animator.sourceNameLabel = sourceCell.nameLabel
        animator.destinationImageView = toVC.imageView
        animator.destinationNameLabel = toVC.nameLabel
        
        return animator
    }
    
    var sourceCell: TableViewCell!
    let animator = ImageTransitionAnimator()
    
    
}

class FriendController {
    
    init() {
        let names: [String] = ["Steve", "Elon"]
        let images: [UIImage] = [#imageLiteral(resourceName: "steve"), #imageLiteral(resourceName: "elon")]
        let jobs: [String] = ["Apple Fanboy", "Paypal Money"]
        
        var index: Int = 0
        
        for _ in names {
            createFriend(withName: names[index], image: images[index], job: jobs[index])
            index += 1
        }
    }
    
    func createFriend(withName name: String, image: UIImage, job: String) {
        let friend = Friend(name: name, image: image, job: job)
        friends.append(friend)
    }
    
    var friends: [Friend] = []
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
}

class TableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.delegate = navigationControllerDelegate
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendController.friends.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendCell", for: indexPath) as! TableViewCell
        
        cell.friend = friendController.friends[indexPath.row]
        
        return cell
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let detailVC = segue.destination as! DetailViewController
        
        guard let indexPath = tableView.indexPathForSelectedRow else { return }
        detailVC.friend = friendController.friends[indexPath.row]
        
        guard let cell = tableView.cellForRow(at: indexPath) as? TableViewCell else { return }
        navigationControllerDelegate.sourceCell = cell
    }
    
    let friendController = FriendController()
    let navigationControllerDelegate = NavigationControllerDelegate()
}

class DetailViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateViews()
    }
    
    func updateViews() {
        guard let friend = friend else { return }
        
        self.title = friend.name
        imageView.image = friend.image
        nameLabel.text = friend.name
        jobLabel.text = friend.job
    }
    
    var friend: Friend?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var jobLabel: UILabel!
}


class ImageTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let toVC = transitionContext.viewController(forKey: .to) as? DetailViewController,
            let toView = transitionContext.view(forKey: .to) else { return }
        
        let containerView = transitionContext.containerView
        
        let toViewEndFrame = transitionContext.finalFrame(for: toVC)
        containerView.addSubview(toView)
        toView.frame = toViewEndFrame
        toView.alpha = 0.0
        
        sourceNameLabel.alpha = 0.0
        sourceImageView.alpha = 0.0
        destinationNameLabel.alpha = 0.0
        destinationImageView.alpha = 0.0
        
        let labelIntialFrame = containerView.convert(sourceNameLabel.bounds, from: sourceNameLabel)
        let animatedNameLabel = UILabel(frame: labelIntialFrame)
        animatedNameLabel.text = sourceNameLabel.text
        animatedNameLabel.font = sourceNameLabel.font
        containerView.addSubview(animatedNameLabel)
        
        let imageInitialFrame = containerView.convert(sourceImageView.bounds, from: sourceImageView)
        let animatedImageView = UIImageView(frame: imageInitialFrame)
        animatedImageView.image = sourceImageView.image
        animatedImageView.contentMode = sourceImageView.contentMode
        containerView.addSubview(animatedImageView)
        
        let duration = transitionDuration(using: transitionContext)
        toView.layoutIfNeeded()
        UIView.animate(withDuration: duration, animations: {
            animatedNameLabel.frame = containerView.convert(self.destinationNameLabel.bounds, from: self.destinationNameLabel)
            animatedImageView.frame = containerView.convert(self.destinationImageView.bounds, from: self.destinationImageView)
            toView.alpha = 1.0
        }) { (success) in
            
            self.sourceNameLabel.alpha = 1.0
            self.sourceImageView.alpha = 1.0
            self.destinationNameLabel.alpha = 1.0
            self.destinationImageView.alpha = 1.0
            animatedNameLabel.removeFromSuperview()
            animatedImageView.removeFromSuperview()
            
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            
        }
        
    }
    
    var sourceImageView: UIImageView!
    var sourceNameLabel: UILabel!
    var destinationImageView: UIImageView!
    var destinationNameLabel: UILabel!
    
}


class TableViewCell: UITableViewCell {
    func updateViews() {
        
        guard let friend = friend else { return }
        nameLabel.text = friend.name
        cellImageView.image = friend.image
    }
    
    @IBOutlet weak var nameLabel: UILabel!

    @IBOutlet weak var cellImageView: UIImageView!
    
    var friend: Friend? {
        didSet {
            updateViews()
        }
    }
    
}
