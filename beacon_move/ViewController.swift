import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var label: UILabel!
    //beaconの値取得関係の変数
    var trackLocationManager : CLLocationManager!
    var beaconRegion : CLBeaconRegion!

    override func viewDidLoad() {
        super.viewDidLoad()

        // ロケーションマネージャを作成する
        trackLocationManager = CLLocationManager();

        // デリゲートを自身に設定
        trackLocationManager.delegate = self;

        // BeaconのUUIDを設定
        let uuid:UUID! = UUID(uuidString:"48534442-4C45-4144-80C0-1800FFFFFFFF");
       

        //Beacon領域を作成
        if(uuid == nil){print("不正なUUIDです")}
        beaconRegion = CLBeaconRegion(proximityUUID:uuid!,identifier: "a")
        //エラー起きる原因がuuidを１６進数で指定していなかったの笑える

        // セキュリティ認証のステータスを取得
        let status = CLLocationManager.authorizationStatus()
        // まだ認証が得られていない場合は、認証ダイアログを表示
        if(status == CLAuthorizationStatus.notDetermined) {
            trackLocationManager.requestWhenInUseAuthorization()
        }
    }

    //位置認証のステータスが変更された時に呼ばれる
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        //観測を開始させる
        trackLocationManager.startMonitoring(for: self.beaconRegion)
        print("観測開始")
    }

    //観測の開始に成功すると呼ばれる
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        //観測開始に成功したら、領域内にいるかどうかの判定をおこなう。→（didDetermineState）へ
        trackLocationManager.requestState(for: self.beaconRegion)
        print("成功")
        label.text="観測を開始しました"
    }

    //領域内にいるかどうかを判定する 状態が変化したら呼び出される
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for inRegion: CLRegion) {
        print("判定開始")
        switch (state) {
        case .inside: // すでに領域内にいる場合は（didEnterRegion）は呼ばれない
            trackLocationManager.startRangingBeacons(in: beaconRegion)
            // →(didRangeBeacons)で測定をはじめる
            label.text="領域内を確認しました"
            break

        case .outside:
            // 領域外→領域に入った場合はdidEnterRegionが呼ばれる
            break

        case .unknown:
            // 不明→領域に入った場合はdidEnterRegionが呼ばれる
            break

        }
    }

    //領域に入った時
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        // →(didRangeBeacons)で測定をはじめる
        self.trackLocationManager.startRangingBeacons(in: self.beaconRegion)
        print("領域内に確認")
    }

    //領域から出た時
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        //測定を停止する
        self.trackLocationManager.stopRangingBeacons(in: self.beaconRegion)
        print("領域外に出たことを確認")
    }

    //領域内にいるので測定をする
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion){
        /*
         beaconから取得できるデータ
         proximityUUID   :   regionの識別子
         major           :   識別子１
         minor           :   識別子２
         proximity       :   相対距離
         accuracy        :   精度
         rssi            :   電波強度
         */
        print(beacons.count)
        label.text="\(CLProximity.self)"
    }
}
