import UIKit
import Neon
import DateToolsSwift

public protocol DayViewDataSource: class {
  func eventsForDate(_ date: Date) -> [EventDescriptor]
}

public protocol DayViewDelegate: class {
  func dayViewDidSelectEventView(_ eventView: EventView)
  func dayViewDidLongPressEventView(_ eventView: EventView)
  func dayViewDidLongPressTimelineAtHour(_ hour: Int)
  func dayView(dayView: DayView, willMoveTo date: Date)
  func dayView(dayView: DayView, didMoveTo  date: Date)
}

public class DayView: UIView {

  public weak var dataSource: DayViewDataSource?
  public weak var delegate: DayViewDelegate?

  /// Hides or shows header view
  public var isHeaderViewVisible = true {
    didSet {
      headerHeight = isHeaderViewVisible ? DayView.headerVisibleHeight : 0
      dayHeaderView.isHidden = !isHeaderViewVisible
      dayHeaderView.delegate = isHeaderViewVisible ? self : nil
      setNeedsLayout()
    }
  }

  public var timelineScrollOffset: CGPoint {
    // Any view is fine as they are all synchronized
    return timelinePager.reusableViews.first?.contentOffset ?? CGPoint()
  }

  static let headerVisibleHeight: CGFloat = 88
  var headerHeight: CGFloat = headerVisibleHeight

  open var autoScrollToFirstEvent = false

  let dayHeaderView = DayHeaderView()
  let timelinePager = PagingScrollView<TimelineContainer>()
  var timelineSynchronizer: ScrollSynchronizer?

  var currentDate = Date().dateOnly()

  var style = CalendarStyle()

  override public init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }

  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    configure()
  }

  func configure() {
    configureTimelinePager()
    dayHeaderView.delegate = self
    addSubview(dayHeaderView)
  }

  public func updateStyle(_ newStyle: CalendarStyle) {
    style = newStyle.copy() as! CalendarStyle
    dayHeaderView.updateStyle(style.header)
    timelinePager.reusableViews.forEach{ timelineContainer in
      timelineContainer.timeline.updateStyle(style.timeline)
      timelineContainer.backgroundColor = style.timeline.backgroundColor
    }
  }

  public func changeCurrentDate(to newDate: Date) {
    let newDate = newDate.dateOnly()
    if newDate.isEarlier(than: currentDate) {
      var timelineDate = newDate
      for (index, timelineContainer) in timelinePager.reusableViews.enumerated() {
        timelineContainer.timeline.date = timelineDate
        timelineDate = timelineDate.add(TimeChunk(seconds: 0, minutes: 0, hours: 0, days: 1, weeks: 0, months: 0, years: 0))
        if index == 0 {
          updateTimeline(timelineContainer.timeline)
        }
      }
      timelinePager.scrollBackward()
    } else if newDate.isLater(than: currentDate) {
      var timelineDate = newDate
      for (index, timelineContainer) in timelinePager.reusableViews.reversed().enumerated() {
        timelineContainer.timeline.date = timelineDate
        timelineDate = timelineDate.subtract(TimeChunk(seconds: 0, minutes: 0, hours: 0, days: 1, weeks: 0, months: 0, years: 0))
        if index == 0 {
          updateTimeline(timelineContainer.timeline)
        }
      }
      timelinePager.scrollForward()
    }
    currentDate = newDate
  }

  public func timelinePanGestureRequire(toFail gesture: UIGestureRecognizer) {
    for timelineContainer in timelinePager.reusableViews {
      timelineContainer.panGestureRecognizer.require(toFail: gesture)
    }
  }
  
  public func scrollTo(hour24: Float) {
    // Any view is fine as they are all synchronized
    timelinePager.reusableViews.first?.scrollTo(hour24: hour24)
  }

  func configureTimelinePager() {
    var verticalScrollViews = [TimelineContainer]()
    for i in -1...1 {
      let timeline = TimelineView(frame: bounds)
      timeline.delegate = self
      timeline.eventViewDelegate = self
      timeline.frame.size.height = timeline.fullHeight
      timeline.date = currentDate.add(TimeChunk(seconds: 0,
                                                minutes: 0,
                                                hours: 0,
                                                days: i,
                                                weeks: 0,
                                                months: 0,
                                                years: 0))

      let verticalScrollView = TimelineContainer()
      verticalScrollView.timeline = timeline
      verticalScrollView.addSubview(timeline)
      verticalScrollView.contentSize = timeline.frame.size

      timelinePager.addSubview(verticalScrollView)
      timelinePager.reusableViews.append(verticalScrollView)
      verticalScrollViews.append(verticalScrollView)
    }
    timelineSynchronizer = ScrollSynchronizer(views: verticalScrollViews)
    addSubview(timelinePager)

    timelinePager.viewDelegate = self
  }

  public func reloadData() {
    timelinePager.reusableViews.forEach{self.updateTimeline($0.timeline)}
  }

  override public func layoutSubviews() {
    super.layoutSubviews()

    let contentWidth = CGFloat(timelinePager.reusableViews.count) * bounds.width
    let size = CGSize(width: contentWidth, height: 50)
    timelinePager.contentSize = size
    timelinePager.contentOffset = CGPoint(x: bounds.width, y: 0)

    dayHeaderView.anchorAndFillEdge(.top, xPad: 0, yPad: 0, otherSize: headerHeight)
    timelinePager.alignAndFill(align: .underCentered, relativeTo: dayHeaderView, padding: 0)
  }

  func updateTimeline(_ timeline: TimelineView) {
    guard let dataSource = dataSource else {return}
    let events = dataSource.eventsForDate(timeline.date)
    timeline.eventDescriptors = events
  }
}

extension DayView: EventViewDelegate {
  func eventViewDidTap(_ eventView: EventView) {
    delegate?.dayViewDidSelectEventView(eventView)
  }
  func eventViewDidLongPress(_ eventview: EventView) {
    delegate?.dayViewDidLongPressEventView(eventview)
  }
}

extension DayView: PagingScrollViewDelegate {
  func updateViewAtIndex(_ index: Int) {
    let timeline = timelinePager.reusableViews[index].timeline
    let amount = index > 1 ? 1 : -1
    timeline?.date = currentDate.add(TimeChunk(seconds: 0,
                                               minutes: 0,
                                               hours: 0,
                                               days: amount,
                                               weeks: 0,
                                               months: 0,
                                               years: 0))
    updateTimeline(timeline!)
  }

  func scrollviewDidScrollToViewAtIndex(_ index: Int) {
    let nextDate = timelinePager.reusableViews[index].timeline.date
    delegate?.dayView(dayView: self, willMoveTo: nextDate)
    currentDate = nextDate
    dayHeaderView.selectDate(currentDate)
    if autoScrollToFirstEvent {
      scrollToFirstEvent()
    }
    delegate?.dayView(dayView: self, didMoveTo: currentDate)
  }

  func scrollToFirstEvent() {
    let index = Int(timelinePager.currentScrollViewPage)
    timelinePager.reusableViews[index].scrollToFirstEvent()
  }
}

extension DayView: DayHeaderViewDelegate {
  public func dateHeaderDateChanged(_ newDate: Date) {
    changeCurrentDate(to: newDate)
  }
}

extension DayView: TimelineViewDelegate {
  func timelineView(_ timelineView: TimelineView, didLongPressAt hour: Int) {
    delegate?.dayViewDidLongPressTimelineAtHour(hour)
  }
}
