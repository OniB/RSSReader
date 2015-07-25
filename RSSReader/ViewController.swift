//
//  ViewController.swift
//  RSSReader
//
//  Created by OniB on 2015/07/14.
//
//

import UIKit
import WebKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,
    NSXMLParserDelegate, UIAlertViewDelegate {

    private var tableView: UITableView!
    
    private var webView: WKWebView?
    
    var urlCheck : Int = 0
    
    //    private var items: [String] = ["１行目", "２行目", "３行目"]
    private var items : [Item] = [Item]()
    
    var currentElementName : String!
    
    let itemElementName : String! = "item"
    let titleElementName : String! = "title"
    let linkElementName : String!  = "link"
    
    // Itemクラス
    class Item {
        var title : String!
        var url : String!
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // StatusBarの高さを取得
        let barHeight: CGFloat = UIApplication.sharedApplication().statusBarFrame.size.height
        
        // Viewの高さと幅を取得
        let displayWidth: CGFloat = self.view.frame.width
        let displayHeight: CGFloat = self.view.frame.height
        
        // 取得したTableViewを生成
        tableView = UITableView(
            frame: CGRect(
                x: 0,
                y: barHeight,
                width: displayWidth,
                height: displayHeight - barHeight
            )
        )
        
        // Cell名の登録
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        
        // DataSourceを設定
        tableView.dataSource = self
        
        // Delegateを設定
        tableView.delegate = self
        
        // Viewに追加
        self.view.addSubview(tableView)
        
        
        // タイトルを設定
        self.title = "RSS Reader"
        
        // 読み込み対象のXMLのパスを指定
        let feedUrl = NSURL(string: "http://www3.asahi.com/rss/index.rdf")
        
        // NSXMLParserクラスのインスタンスを初期化・生成
        let parser = NSXMLParser(contentsOfURL: feedUrl!)
        
        // 読み込み時に呼び出すデリゲードクラスを指定し、XMLの読み込みを開始する
        if parser != nil {
            parser!.delegate = self
            parser!.parse()
        }
        
        // TableViewの更新ボタンをナビゲーションバーの右側に追加
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .Refresh,
            target: self,
            action: "reloadTable"
        )
        
        // RSSの変更ボタンをナビゲーションバーの左側に追加
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .Action,
            target: self,
            action: "changeRSS"
        )
    }
    
    /*
    RSSを変更するメソッド
    */
    func changeRSS(){
        //AlertControllerの初期化・生成
        let alert: UIAlertController = UIAlertController(
            title: "RSSの更新", message: nil, preferredStyle: .Alert
        )
        
        // Actionを作成
        let rss1: UIAlertAction = UIAlertAction(title: "記事１", style: .Default,
            handler:{(action:UIAlertAction!) -> Void in
                    self.urlCheck = 0 // チェッカーを指定
                    self.reloadTable() // テーブルの更新
            })
        let rss2: UIAlertAction = UIAlertAction(title: "記事２", style: .Default,
            handler:{(action:UIAlertAction!) -> Void in
                self.urlCheck = 1 // チェッカーを指定
                self.reloadTable() // テーブルの更新
            })
        let rss3: UIAlertAction = UIAlertAction(title: "記事３", style: .Default,
            handler:{
                (action:UIAlertAction!) -> Void in
                self.urlCheck = 2 // チェッカーを指定
                self.reloadTable() // テーブルの更新
            })
        let cancel: UIAlertAction = UIAlertAction(
            title: "キャンセル",
            style: .Cancel,
            handler: nil
        )
        
        // Actionを追加
        alert.addAction(rss1)
        alert.addAction(rss2)
        alert.addAction(rss3)
        alert.addAction(cancel)
        
        //UIAlert表示
        presentViewController(alert, animated: true, completion: nil)
    }
    

    /*
    tableViewを更新するメソッド
    */
    func reloadTable(){
        // Item配列を初期化
        items = [Item]()
        
        // 読み込み対象のXMLのパスを指定
        var feedUrl = NSURL(string: "http://www3.asahi.com/rss/index.rdf")
        
        if (urlCheck == 1) {
            feedUrl = NSURL(string: "http://itpro.nikkeibp.co.jp/rss/news.rdf")
        }
        else if (urlCheck == 2) {
            feedUrl = NSURL(string: "http://www.watch.impress.co.jp/game/sublink/game.rdf")
        }
        
        // NSXMLParserクラスのインスタンスを初期化・生成
        let parser = NSXMLParser(contentsOfURL: feedUrl!)
        
        // 読み込み時に呼び出すデリゲードクラスを指定し、XMLの読み込みを開始する
        if parser != nil {
            parser!.delegate = self
            parser!.parse()
        }
        
        // tableViewを更新する
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /*
    Cellの総数を返すデータソースメソッド（実装必須）
    */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    /*
    Cellに値を設定するデータソースメソッド（実装必須）
    */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) ->
        UITableViewCell {
            
        let cell: UITableViewCell = UITableViewCell(style: .Subtitle, reuseIdentifier: "Cell")
        // cell.textLabel?.text = items[indexPath.row]
        cell.textLabel?.text = items[indexPath.row].title
        return cell
            
    }
    
    /*
    Cellが選択された際に呼び出されるデリゲートメソッド
    */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let item = items[indexPath.row]
        let openUrl = NSURL(string: item.url)
        
        // WKWebViewを生成
        webView = WKWebView()
        
        // NSURLRequstを生成
        let request: NSURLRequest = NSURLRequest(URL: openUrl!)
        
        // ロード
        webView!.loadRequest(request)
        
        // Viewを新規作成
        let webViewController : ViewController = ViewController()
        
        // 新規作成したViewをWKWebViewに設定
        webViewController.view = webView!
        
        // 新規作成したViewに移動
        self.navigationController?.pushViewController(webViewController, animated: true)
    }
    
    /*
    要素の開始タグを読み込んだ時
    */
    func parser(parser: NSXMLParser, didStartElement elementName: String,
        namespaceURI: String?, qualifiedName qName: String?,
        attributes attributeDict: [NSObject : AnyObject]) {
        
        currentElementName = nil
        if elementName == itemElementName {
            items.append(Item())
        } else {
            currentElementName = elementName
        }
        
    }
    
    /*
    タグ以外のテキストを読み込んだ時
    */
    func parser(parser: NSXMLParser, foundCharacters string: String?) {
        
        if items.count > 0 {
            let lastItem = items[items.count-1]
            if currentElementName != nil {
                if currentElementName == titleElementName {
//                    if lastItem.title != nil {
//                        lastItem.title? += string!
//                    } else {
//                        lastItem.title = string!
//                    }
                    lastItem.title = string
                } else if currentElementName == linkElementName {
                    lastItem.url = string
                }
            }
        }
        
    }
    
    /*
    要素の終了タグを読み込んだ時
    */
    func parser(parser: NSXMLParser, didEndElement elementName: String,
        namespaceURI: String?, qualifiedName qName: String?) {
        currentElementName = nil
    }
    
}