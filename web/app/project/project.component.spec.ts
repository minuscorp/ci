import 'rxjs/add/operator/switchMap';

import {async, ComponentFixture, TestBed} from '@angular/core/testing';
import {MatCardModule} from '@angular/material/card';
import {MatIconModule} from '@angular/material/icon';
import {MatTableModule} from '@angular/material/table';
import {MatToolbarModule} from '@angular/material/toolbar';
import {MatProgressSpinnerModule} from '@angular/material/progress-spinner';
import {MomentModule} from 'ngx-moment';
import {ActivatedRoute, convertToParamMap} from '@angular/router';
import {Observable} from 'rxjs/Observable';
import {Subject} from 'rxjs/Subject';

import {Project} from '../models/project';
import {DataService} from '../services/data.service';

import {ProjectComponent} from './project.component';
import {mockProject} from './test_helpers/mock_project_response';

describe('ProjectComponent', () => {
  let component: ProjectComponent;
  let fixture: ComponentFixture<ProjectComponent>;
  let dataService: jasmine.SpyObj<Partial<DataService>>;

  beforeEach(async(() => {
    dataService = {getProject: jasmine.createSpy()};

    TestBed
        .configureTestingModule({
          imports:
              [MatIconModule, MatCardModule, MatTableModule, MatToolbarModule, MatProgressSpinnerModule, MomentModule],
          declarations: [
            ProjectComponent,
          ],
          providers: [
            {provide: DataService, useValue: dataService}, {
              provide: ActivatedRoute,
              useValue:
                  {paramMap: Observable.of(convertToParamMap({id: '123'}))}
            }
          ],
        })
        .compileComponents();

    fixture = TestBed.createComponent(ProjectComponent);
    component = fixture.componentInstance;
  }));

  it('should load project', () => {
    const subject = new Subject<Project>();
    dataService.getProject.and.returnValue(subject.asObservable());

    expect(component.isLoading).toBe(true);

    fixture.detectChanges();  // onInit()
    expect(dataService.getProject).toHaveBeenCalledWith('123');
    subject.next(mockProject);  // Resolve observable

    expect(component.isLoading).toBe(false);
    expect(component.project.id).toBe('12');
    expect(component.project.name).toBe('the most coolest project');
    expect(component.project.builds.length).toBe(2);
    expect(component.project.builds[0].sha).toBe('asdfshzdggfdhdfh4');
  });
});
