//
//  ViewController.swift
//  beacon_move
//
//  Created by kiyolab02 on 2019/08/30.
//  Copyright © 2019年 miraikeitai2019. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController , CLLocationManagerDelegate {
    
    private var _locationManager: CLLocationManager!
    private var _beaconRegion: CLBeaconRegion!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // ビーコンの探索開始
        if (checkForLocationServices()) {
            // ロケーションマネージャーの設定
            self._locationManager = CLLocationManager()
            self._locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self._locationManager.allowsBackgroundLocationUpdates = true
            self._locationManager.showsBackgroundLocationIndicator = true
            self._locationManager.delegate = self
            
            // 初回起動時は、アプリが位置情報を利用することの許可をとる
            if (CLLocationManager.authorizationStatus() == .notDetermined) {
                self._locationManager.requestAlwaysAuthorization()
            }
        }
        else{
            print("ERROR: ビーコン探索を開始できませんでした")
        }
    }
    
    // didChangeAuthorization：アプリへの位置情報の許可状況が変化した時
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("Delegate: didChangeAuthorization")
        
        // アプリ起動中、位置情報の許可が変化すると呼ばれる
        if (status == .authorizedAlways) {
            print("INFO: 位置情報 always")
            startMonitoringBeacons(clLocatonManager: manager)
        }
        else if (status == .authorizedWhenInUse) {
            print("INFO: 位置情報 when in use")
            print("INFO: 位置情報は常に許可してください")
        }
        else if (status == .notDetermined) {
            print("INFO: 位置情報 notDetermined")
        }
        else if (status == .denied) {
            print("INFO: 位置情報 denied")
        }
        else if (status == .restricted) {
            print("INFO: 位置情報 restricted")
        }
    }
    
    // didStartMonitoringFor：Regionの探索が開始されたとき
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        print("Delegate: didStartMonitoringFor")
        // 既に検知しているビーコンがないか確認
        if (region is CLBeaconRegion) {
            manager.requestState(for: region as! CLBeaconRegion)
        }
    }
    
    // didEnterRegion：探索条件に合ったiBeacon情報が格納されたRegionが最初に検知されたとき
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        // 今回は使わないやり方にしました
        print("Delegate: didEnterRegion")
    }
    
    // didExitRegion：Regionの探索条件に合ったiBeaconが全て検知されなくなったとき
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        // 今回は使わないやり方にしました
        print("Delegate: didExitRegion")
    }
    
    // didDetermineState：didEnterRegion、didExitRegionが発生したとき、
    // CLLocationManager#requestState()が実行されたとき
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        print("Delegate: didDetermineState")
        
        // リージョンの状態ごとに処理をわける（ここでは重い処理はしない方がよさそうです）
        if (state == .inside) {
            // アプリ起動時に既にビーコンを受信していた場合にも対応
            if (!CLLocationManager.isRangingAvailable()) {
                print("ERROR: レンジングに対応していません")
            }
            else if(!manager.rangedRegions.contains(region)){
                // Regionがまだレンジングされていなければ、レンジングを開始する
                if (region is CLBeaconRegion) {
                    manager.startRangingBeacons(in: region as! CLBeaconRegion)
                    print("INFO : didDetermineState_inside, id= ", region.identifier)
                }
            }
        }
        else if (state == .outside) {
            if(manager.rangedRegions.contains(region)){
                // Regionがまだレンジングされていたら、レンジングを終了する
                if (region is CLBeaconRegion) {
                    manager.stopRangingBeacons(in: region as! CLBeaconRegion)
                    print("INFO : didDetermineState_outside, id= ", region.identifier)
                }
            }
        }
        else if (state == .unknown) {
            print("INFO : didDetermineState_unknown, id= ", region.identifier)
        }
    }
    
    // didRangeBeacons：レンジング中にiBeacon情報が到着したとき
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        print("Delegate: didRangeBeacons")
        print("INFO: レンジング中のビーコン数 = ", beacons.count)
    }
    
    // rangingBeaconsDidFailFor：レンジング中にエラーが発生したとき
    func locationManager(_ manager: CLLocationManager, rangingBeaconsDidFailFor region: CLBeaconRegion, withError error: Error) {
        print("Delegate: rangingBeaconsDidFailFor")
        // エラー内容の出力
        print("ERROR: ", error)
    }
    
    
    private func checkForLocationServices() -> Bool {
        
        if (CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self)) {
            print("INFO: 探索に対応しています")
        }else{
            print("ERROR: 探索に対応していません")
            return (false)
        }
        
        if (CLLocationManager.locationServicesEnabled()) {
            print("INFO: 位置情報はONです")
        }else{
            print("ERROR: 位置情報はOffです")
            return (false)
        }
        
        return (true)
    }
    
    // 探索するCLBeaconRegionのインスタンス生成と探索開始
    private func startMonitoringBeacons(clLocatonManager manager: CLLocationManager) {
        // BeaconRegionがnilだったら新規に探索を開始
        if (self._beaconRegion != nil) {
            print("INFO: 既にRegionを探索中です")
        }
        else{
            // 探索するUUIDの指定
            let uuid: NSUUID? = NSUUID(uuidString: "48534442-4C45-4144-80C0-1800FFFFFFF2")
            let major: CLBeaconMajorValue = 100
            let minor: CLBeaconMinorValue = 100
            let beaconID: String = "jp.co.houwa-js.test.blog"
            
            // 探索の設定
            if let pxuuid = uuid{
                self._beaconRegion = CLBeaconRegion(proximityUUID: pxuuid as UUID,
                                                    major: major,
                                                    minor: minor,
                                                    identifier: beaconID)
                self._beaconRegion.notifyEntryStateOnDisplay = false
                self._beaconRegion.notifyOnEntry = true
                self._beaconRegion.notifyOnExit = true
                
                // 探索開始
                manager.startMonitoring(for: self._beaconRegion)
                print("INFO: Regionの探索を開始しました")
                
            }else{
                print("ERROR: UUIDが空です")
            }
        }
    }
    
    


}

