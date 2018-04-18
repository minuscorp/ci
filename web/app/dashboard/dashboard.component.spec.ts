import 'rxjs/add/observable/of';

import {async, ComponentFixture, fakeAsync, TestBed, tick} from '@angular/core/testing';
import {MatCardModule} from '@angular/material/card';
import {MatIconModule} from '@angular/material/icon';
import {MatTableModule} from '@angular/material/table';
import {MatProgressSpinnerModule} from '@angular/material/progress-spinner';
import {RouterModule} from '@angular/router';
import {MomentModule} from 'ngx-moment';
import {Observable} from 'rxjs/Observable';
import {Subject} from 'rxjs/Subject';

import {BuildStatus} from '../common/constants';
import {ProjectSummary} from '../models/project_summary';
import {DataService} from '../services/data.service';

import {DashboardComponent} from './dashboard.component';
import {mockProjectSummaryList} from './test_helpers/mock_project_summary';

describe('DashboardComponent', () => {
  let component: DashboardComponent;
  let fixture: ComponentFixture<DashboardComponent>;
  let dataService: jasmine.SpyObj<Partial<DataService>>;

  beforeEach(() => {
    dataService = {getProjects: jasmine.createSpy()};

    TestBed
        .configureTestingModule({
          imports: [
            MatIconModule, MatCardModule, MatTableModule, MatProgressSpinnerModule, RouterModule,
            MomentModule
          ],
          declarations: [
            DashboardComponent,
          ],
          providers: [{provide: DataService, useValue: dataService}],
        })
        .compileComponents();

    fixture = TestBed.createComponent(DashboardComponent);
    component = fixture.componentInstance;
  });

  it('should load project summaries', () => {
    const subject = new Subject<ProjectSummary[]>();
    dataService.getProjects.and.returnValue(subject.asObservable());

    expect(component.isLoading).toBe(true);

    fixture.detectChanges();               // onInit()
    subject.next(mockProjectSummaryList);  // Resolve observable

    expect(component.isLoading).toBe(false);
    expect(component.projects.length).toBe(4);
    expect(component.projects[0].id).toBe('1');
    expect(component.projects[0].name).toBe('the coolest project');
    expect(component.projects[1].latestStatus).toBe(BuildStatus.SUCCESS);
    expect(component.projects[2].statusIcon).toBe('error');
    expect(component.projects[3].latestDate).toBeUndefined();
    expect(component.projects[3].statusIcon).toBe('pause_circle_filled');
  });
});
