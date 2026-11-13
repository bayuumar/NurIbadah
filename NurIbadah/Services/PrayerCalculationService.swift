import Foundation

// MARK: - Astronomical Prayer Times Calculator (100% Offline)
/// Implementasi rumus astronomis posisi matahari untuk jadwal sholat
/// Sesuai standar Kemenag RI (Subuh 20°, Isya 18°, Asr Madzhab Syafi'i)
final class PrayerCalculationService {
    static let shared = PrayerCalculationService()
    
    private init() {}
    
    // MARK: - Public Calculation API
    /// Menghitung jadwal sholat lengkap untuk tanggal dan koordinat tertentu
    func calculateSchedule(
        for date: Date,
        latitude: Double,
        longitude: Double,
        timezoneOffsetHours: Double,
        method: CalculationMethod = .kemenag,
        ihtiyatMinutes: Int = 2
    ) -> PrayerSchedule {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        
        let jd = julianDay(year: year, month: month, day: day)
        let sunPos = sunPosition(julianDay: jd)
        
        // Waktu Solar Noon / Dzuhur astronomis dalam jam desimal (0-24)
        let solarNoon = 12.0 + timezoneOffsetHours - (longitude / 15.0) - sunPos.equationOfTime
        
        // Sudut-sudut matahari:
        // Subuh: sudut depresi (Kemenag = 20°)
        let fajrHourAngle = sunHourAngle(altitude: -method.fajrAngle, latitude: latitude, declination: sunPos.declination)
        
        // Terbit: matahari menyentuh ufuk (-0.833° untuk radius cakram 16' dan refraksi 34')
        let sunriseHourAngle = sunHourAngle(altitude: -0.833, latitude: latitude, declination: sunPos.declination)
        
        // Ashar: bayangan objek = panjang objek + bayangan saat dzuhur (Syafi'i: rasio 1)
        let asrAltitude = asrSunAltitude(latitude: latitude, declination: sunPos.declination, shadowFactor: 1.0)
        let asrHourAngle = sunHourAngle(altitude: asrAltitude, latitude: latitude, declination: sunPos.declination)
        
        // Maghrib: matahari terbenam (-0.833°)
        let sunsetHourAngle = sunHourAngle(altitude: -0.833, latitude: latitude, declination: sunPos.declination)
        
        // Isya: sudut depresi (Kemenag = 18°)
        let ishaHourAngle: Double?
        if method.isIshaInterval {
            ishaHourAngle = nil
        } else {
            ishaHourAngle = sunHourAngle(altitude: -method.ishaAngle, latitude: latitude, declination: sunPos.declination)
        }
        
        // Konversi jam desimal ke waktu
        let bufferHours = Double(ihtiyatMinutes) / 60.0
        
        var times: [PrayerType: Date] = [:]
        
        // Dzuhur: Transit + ihtiyat
        let dzuhurDecimal = solarNoon + bufferHours
        if let d = dateFromDecimalHours(dzuhurDecimal, baseDate: date) {
            times[.dzuhur] = d
        }
        
        // Terbit
        if let sunH = sunriseHourAngle {
            let sunriseDecimal = solarNoon - sunH
            if let d = dateFromDecimalHours(sunriseDecimal, baseDate: date) {
                times[.terbit] = d
            }
        }
        
        // Subuh
        if let fajrH = fajrHourAngle {
            let subuhDecimal = solarNoon - fajrH + bufferHours
            if let d = dateFromDecimalHours(subuhDecimal, baseDate: date) {
                times[.subuh] = d
            }
        }
        
        // Ashar
        if let asrH = asrHourAngle {
            let asharDecimal = solarNoon + asrH + bufferHours
            if let d = dateFromDecimalHours(asharDecimal, baseDate: date) {
                times[.ashar] = d
            }
        }
        
        // Maghrib
        if let maghribH = sunsetHourAngle {
            let maghribDecimal = solarNoon + maghribH + bufferHours
            if let d = dateFromDecimalHours(maghribDecimal, baseDate: date) {
                times[.maghrib] = d
            }
            
            // Isya (bisa dari sudut atau interval)
            if method.isIshaInterval {
                let ishaDecimal = maghribDecimal + (Double(method.ishaIntervalMinutes) / 60.0)
                if let d = dateFromDecimalHours(ishaDecimal, baseDate: date) {
                    times[.isya] = d
                }
            } else if let ishaH = ishaHourAngle {
                let ishaDecimal = solarNoon + ishaH + bufferHours
                if let d = dateFromDecimalHours(ishaDecimal, baseDate: date) {
                    times[.isya] = d
                }
            }
        }
        
        return PrayerSchedule(date: date, times: times)
    }
    
    // MARK: - Astronomical Calculations
    
    /// Julian Day dari tanggal Gregorian
    private func julianDay(year: Int, month: Int, day: Int) -> Double {
        var y = Double(year)
        var m = Double(month)
        let d = Double(day)
        
        if m <= 2 {
            y -= 1
            m += 12
        }
        
        let a = floor(y / 100.0)
        let b = 2.0 - a + floor(a / 4.0)
        
        return floor(365.25 * (y + 4716.0)) + floor(30.6001 * (m + 1.0)) + d + b - 1524.5
    }
    
    /// Posisi Matahari: Deklinasi dan Persamaan Waktu (Equation of Time)
    private func sunPosition(julianDay: Double) -> (declination: Double, equationOfTime: Double) {
        let d = julianDay - 2451545.0 // Hari sejak J2000.0
        
        // Rata-rata Anomali Matahari (g) dalam derajat
        let g = fixAngle(357.529 + 0.98560028 * d)
        
        // Rata-rata Bujur Matahari (q) dalam derajat
        let q = fixAngle(280.459 + 0.98564736 * d)
        
        // Bujur Ekliptika Matahari (L)
        let gRad = degreesToRadians(g)
        let l = fixAngle(q + 1.915 * sin(gRad) + 0.020 * sin(2.0 * gRad))
        let lRad = degreesToRadians(l)
        
        // Kemiringan Ekliptika (e) dalam derajat
        let e = 23.439 - 0.00000036 * d
        let eRad = degreesToRadians(e)
        
        // Deklinasi Matahari (delta)
        let sinDelta = sin(eRad) * sin(lRad)
        let declination = radiansToDegrees(asin(sinDelta))
        
        // Asensio Rekta Matahari (RA)
        let cosDelta = cos(asin(sinDelta))
        let sinRA = (cos(eRad) * sin(lRad)) / cosDelta
        let cosRA = cos(lRad) / cosDelta
        var ra = radiansToDegrees(atan2(sinRA, cosRA))
        ra = fixAngle(ra) / 15.0 // dalam jam
        
        // Persamaan Waktu (Equation of Time) dalam jam
        let equationOfTime = (q / 15.0) - ra
        
        return (declination, equationOfTime)
    }
    
    /// Sudut Jam Matahari (Hour Angle) untuk ketinggian matahari tertentu
    private func sunHourAngle(altitude: Double, latitude: Double, declination: Double) -> Double? {
        let altRad = degreesToRadians(altitude)
        let latRad = degreesToRadians(latitude)
        let decRad = degreesToRadians(declination)
        
        let cosH = (sin(altRad) - sin(latRad) * sin(decRad)) / (cos(latRad) * cos(decRad))
        
        // Jika matahari tidak pernah mencapai ketinggian tersebut (polar day/night)
        if cosH > 1.0 || cosH < -1.0 {
            return nil
        }
        
        let hRad = acos(cosH)
        let hDeg = radiansToDegrees(hRad)
        return hDeg / 15.0 // konversi derajat ke jam (15° = 1 jam)
    }
    
    /// Ketinggian matahari pada waktu Ashar (Madzhab Syafi'i: faktor bayangan = 1.0)
    private func asrSunAltitude(latitude: Double, declination: Double, shadowFactor: Double) -> Double {
        let latRad = degreesToRadians(latitude)
        let decRad = degreesToRadians(declination)
        
        // Selisih lintang dan deklinasi
        let diff = abs(latRad - decRad)
        let cotT = shadowFactor + tan(diff)
        let altRad = atan(1.0 / cotT)
        
        return radiansToDegrees(altRad)
    }
    
    // MARK: - Helper Methods
    private func fixAngle(_ angle: Double) -> Double {
        var a = angle.truncatingRemainder(dividingBy: 360.0)
        if a < 0 { a += 360.0 }
        return a
    }
    
    private func degreesToRadians(_ degrees: Double) -> Double {
        degrees * .pi / 180.0
    }
    
    private func radiansToDegrees(_ radians: Double) -> Double {
        radians * 180.0 / .pi
    }
    
    private func dateFromDecimalHours(_ hours: Double, baseDate: Date) -> Date? {
        var normalizedHours = hours
        while normalizedHours < 0 { normalizedHours += 24.0 }
        while normalizedHours >= 24.0 { normalizedHours -= 24.0 }
        
        let hour = Int(normalizedHours)
        let minuteFraction = (normalizedHours - Double(hour)) * 60.0
        let minute = Int(minuteFraction)
        let second = Int((minuteFraction - Double(minute)) * 60.0)
        
        var calendar = Calendar.current
        calendar.timeZone = .current
        var components = calendar.dateComponents([.year, .month, .day], from: baseDate)
        components.hour = hour
        components.minute = minute
        components.second = second
        
        return calendar.date(from: components)
    }
}
